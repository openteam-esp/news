# encoding: utf-8

require 'spec_helper'

describe Entry do
  it { should belong_to :destroy_entry_job }
  it { should have_many(:assets) }
  it { should have_many(:images) }
  it { should have_many(:videos) }
  it { should have_many(:audios) }
  it { should have_many(:attachments) }
  it { should have_many(:tasks).dependent(:destroy) }

  it { should normalize_attribute(:title).from(nil).to(nil) }
  it { should normalize_attribute(:title).from("  ").to(nil) }
  it { should normalize_attribute(:title).from("кое-как").to("кое-как") }
  it { should normalize_attribute(:title).from("  das  asf\n").to("das asf") }
  it { should normalize_attribute(:title).from('"Томск - как центр инновационной культуры"').to("«Томск – как центр инновационной культуры»") }
  it { should normalize_attribute(:annotation).from("<em><script>alert();</script>Hi</em>\ndas  asf\n").to("<em>alert();Hi</em>\ndas&nbsp;asf") }
  it { should normalize_attribute(:annotation).from('"Томск - как центр инновационной культуры"').to("&laquo;Томск &ndash; как&nbsp;центр инновационной культуры&raquo;") }
  it { should normalize_attribute(:body).from("<em><script>alert();</script>Hi</em>\ndas  asf\n").to("<em>alert();Hi</em>\ndas&nbsp;asf") }

  it 'должна корректно сохранять и отображать дату' do
    I18n.l(draft(:since => "19.07.2011 09:20").since, :format => :datetime).should == "19.07.2011 09:20"
  end

  describe "разделяются на папки" do
    let(:draft) { Entry.folder(:draft) }
    let(:processing) { Entry.folder(:processing) }
    let(:deleted) { Entry.folder(:deleted) }

    shared_examples_for "личные" do
      it "черновики" do
        draft.should have_entries.with_state(:draft).created_by_me.not_deleted.ordered_by(:id, :desc)
      end
      it "в корзине" do
        deleted.should have_entries.deleted_by_me.ordered_by(:id, :desc)
      end
    end

    shared_examples_for "общие в работе" do
      it "в работе" do
        processing.should have_entries.with_states(:correcting, :publishing).not_deleted.ordered_by(:id, :desc)
      end
    end

    describe "для инициатора" do
      before { set_current_user(initiator) }
      it_behaves_like "личные"
      it "в работе" do
        processing.should have_entries.with_states(:correcting, :publishing).created_by_me.not_deleted.ordered_by(:id, :desc)
      end
    end

    describe "для корректора" do
      before { set_current_user(initiator(:roles => :corrector)) }
      it_behaves_like "личные"
      it_behaves_like "общие в работе"
    end


    describe "публикатора" do
      before { set_current_user(initiator(:roles => :publisher)) }
      it_behaves_like "личные"
      it_behaves_like "общие в работе"
    end

    describe "корректора и публикатора" do
      before { set_current_user(initiator(:roles => [:corrector, :publisher])) }
      it_behaves_like "личные"
      it_behaves_like "общие в работе"
    end

  end

  describe "после сохранения" do
    before(:each) do
      set_current_user initiator
    end
    let (:prepare) { draft.prepare }
    let (:review) { draft.review }
    let (:publish) { draft.publish }

    describe "задача подготовки" do
      it { prepare.initiator.should == initiator }
      it { prepare.executor.should == initiator }
      it { prepare.state.should == 'processing' }
    end

    describe "задача корретировки" do
      it { review.initiator.should == initiator }
      it { review.executor.should == nil }
      it { review.state.should == 'pending' }
    end

    describe "задача публикации" do
      it { publish.initiator.should == initiator }
      it { publish.executor.should == nil }
      it { publish.state.should == 'pending' }
    end
  end

  it "при публикации, если нет канала, должна быть ошибка" do
    set_current_user corrector_and_publisher
    processing_publishing.channels = []
    processing_publishing.save!
    expect { processing_publishing.publish.complete! }.to raise_error
  end

  describe "блокировка" do
    before do
      set_current_user initiator
    end
    it "при блокировки должна сохранять когда и кем заблокирована" do
      draft.lock
      draft.locked?.should be true
      draft.locked_at.should > Time.now - 5.seconds
      draft.locked_by.should == initiator
    end

    it "сохранение новости, должно ее разблокировать" do
      draft(:locked_at => Time.now).save!
      draft.should_not be_locked
      draft.locked_at.should be_nil
      draft.locked_by.should be_nil
    end
  end

  describe "корзина" do
    before { set_current_user(initiator) }
    describe "удаление" do
      it { deleted_draft.should be_persisted }
      it { deleted_draft.should be_deleted }
      it { draft.destroy_without_trash.should_not be_persisted }
      it "должно типа удалять таски" do
        tasks = []
        draft.should_receive(:tasks).and_return(tasks)
        tasks.should_receive(:update_all)
        draft.destroy
      end
    end

    describe "восстановление" do
      it {recycled_draft.should_not be_deleted}
      it "должно восстановить таски" do
        tasks = []
        deleted_draft.should_receive(:tasks).and_return(tasks)
        tasks.should_receive(:update_all).with(:deleted_at => nil)
        deleted_draft.recycle
      end
    end
  end


  describe "после публикации" do
    before do
      processing_publishing.channels << Fabricate(:channel)
    end
    it "должна поставиться дата публикации (если не установлена)" do
      as publisher do processing_publishing.publish.complete! end
      processing_publishing.since.should_not be nil
      processing_publishing.since.should > Time.now - 1.seconds
    end

    it "не должна изменяться установленная дата публикации" do
      processing_publishing.update_attribute(:since, Time.new(2011, 10, 3, 9, 0, 30))
      as publisher do processing_publishing.publish.complete! end
      processing_publishing.since.should == Time.new(2011, 10, 3, 9, 0, 30)
    end
  end

end

# == Schema Information
#
# Table name: entries
#
#  id            :integer         not null, primary key
#  title         :text
#  annotation    :text
#  body          :text
#  since         :datetime
#  until         :datetime
#  state         :string(255)
#  author        :string(255)
#  initiator_id  :integer
#  created_at    :datetime
#  updated_at    :datetime
#  legacy_id     :integer
#  locked_at     :datetime
#  locked_by_id  :integer
#  deleted_by_id :integer
#

