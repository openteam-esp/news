# encoding: utf-8

require 'spec_helper'

describe NewsEntry do
  it { should have_many(:tasks).dependent(:destroy) }
  it { should have_many(:events).dependent(:destroy) }

  it { should normalize_attribute(:title).from(nil).to(nil) }
  it { should normalize_attribute(:title).from("  ").to(nil) }
  it { should normalize_attribute(:title).from("кое-как").to("кое-как") }
  it { should normalize_attribute(:title).from("  das  asf\n").to("das asf") }
  it { should normalize_attribute(:title).from('"Томск - как центр инновационной культуры"').to("«Томск – как центр инновационной культуры»") }
  it { should normalize_attribute(:annotation).from("<em><script>alert();</script>Hi</em>\ndas  asf\n").to("<em>alert();Hi</em>\ndas&nbsp;asf") }
  it { should normalize_attribute(:annotation).from('"Томск - как центр инновационной культуры"').to("&laquo;Томск &ndash; как&nbsp;центр инновационной культуры&raquo;") }
  it { should normalize_attribute(:body).from("<em><script>alert();</script>Hi</em>\ndas  asf\n").to("<em>alert();Hi</em>\ndas&nbsp;asf") }
  it { should normalize_attribute(:body).from("\r<p style='text-align: right;'>&#13;Signature</p>").to('<p style="text-align: right;">Signature</p>') }
  it { should normalize_attribute(:body).from("<table class='bordered'><tr><td>I'm a table</td></tr></table>").to("<table class=\"bordered\">\n<tr>\n<td>I'm a&nbsp;table</td>\n</tr>\n</table>") }
  it { should normalize_attribute(:body).from("Первая строка\n<hr />\nВторая строка").to("Первая строка\n<hr />\nВторая строка") }
  it { should normalize_attribute(:body).from("Первая строка\n<hr>\nВторая строка").to("Первая строка\n<hr />\nВторая строка") }
  it { should normalize_attribute(:body).from("(C)").to("(C)") }
  it { should normalize_attribute(:body).from("(R)").to("(R)") }
  it { should normalize_attribute(:body).from("(TM)").to("(TM)") }
  it { should normalize_attribute(:body).from("(P)").to("(P)") }
  it { should normalize_attribute(:body).from('<video poster="file.jpg"></video>').to('<video poster="file.jpg"></video>') }
  it { should normalize_attribute(:body).from('<source src="file.mp4" type="video/mp4" />').to('<source src="file.mp4" type="video/mp4"></source>') }

  describe ".folder" do
    let(:folder_draft)       { Entry.folder(:draft, current_user) }
    let(:folder_processing)  { Entry.folder(:processing, current_user) }
    let(:folder_deleted)     { Entry.folder(:deleted, current_user) }

    shared_examples_for "личные" do
      it "черновики" do
        folder_draft.should have_entries.with_state(:draft).created_by(current_user).not_deleted.ordered_by(:id, :desc)
      end
      it "в корзине" do
        folder_deleted.should have_entries.deleted_by(current_user).ordered_by(:id, :desc)
      end
    end

    shared_examples_for "общие в работе" do
      it { folder_processing.should have_entries.with_states(:correcting, :publishing).not_deleted.ordered_by(:id, :desc) }
    end

    context "для инициатора" do
      let(:current_user) { initiator }
      it_behaves_like "личные"
      it "в работе" do
        folder_processing.should have_entries.with_states(:correcting, :publishing).created_by(current_user).not_deleted.ordered_by(:id, :desc)
      end
    end

    context "для корректора" do
      let(:current_user) { corrector }
      it_behaves_like "личные"
      it_behaves_like "общие в работе"
    end


    context "публикатора" do
      let(:current_user) { publisher }
      it_behaves_like "личные"
      it_behaves_like "общие в работе"
    end

    context "корректора и публикатора" do
      let(:current_user) { corrector_and_publisher }
      it_behaves_like "личные"
      it_behaves_like "общие в работе"
    end

  end

  context "в процессе публикации" do
    subject { processing_publishing }

    context "с каналами" do
      before { subject.channels = [channel] }

      it "должна успешно опубликоваться" do
        expect { subject.publish.complete! }.to_not raise_error
      end

      context 'после публикации' do
        before { subject.publish.complete! }
        its(:since) { should > Time.now - 1.second  }
      end
    end

    context 'без каналов' do
      it { expect { subject.publish.complete! }.to raise_error }
    end
  end

  context 'блокировка' do
    subject { draft }

    describe '#lock' do
      before { draft.lock }
      it { should be_locked }
      its(:locked_at) { should > Time.now - 5.seconds }
      its(:locked_by) { should == initiator_of(channel) }
    end

    context 'заблокированная новость' do
      subject { draft.tap do |draft| draft.locked_at = Time.now end}

      describe '#save' do
        before { subject.save! }
        it { should_not be_locked }
        its(:locked_at) { should be_nil }
        its(:locked_by) { should be_nil }
      end
    end
  end

  context 'trash' do
    context 'deleted_draft' do
      it { deleted_draft.should be_persisted }
      it { deleted_draft.should be_deleted }
    end
    describe '#move_to_trash' do
      it "должно маркировать таски флагом удалено" do
        tasks = []
        draft.should_receive(:tasks).and_return(tasks)
        tasks.should_receive(:update_all)
        draft.move_to_trash
      end
    end

    it {revivified_draft.should_not be_deleted}
    describe '#revivify' do
      it "должно восстановить таски" do
        tasks = []
        deleted_draft.should_receive(:tasks).and_return(tasks)
        tasks.should_receive(:update_all).with(:deleted_at => nil)
        deleted_draft.revivify
      end
    end
  end

  describe 'should send message to queue <esp.news.cms>' do
    let(:message) {
      { :slug => 'novost-zagolovok-novosti', :channel_ids => [1] }
    }

    before { MessageMaker.stub(:make_message) }

    describe 'with routing key <publish> when it publish' do
      before { MessageMaker.should_receive(:make_message).with('esp.news.cms', 'publish', message) }

      specify { published }
    end

    describe 'with routing key <remove> when it removed from publication' do
      let(:publishing_entry) {
        published.down
      }

      before { MessageMaker.should_receive(:make_message).with('esp.news.cms', 'remove', message) }

      specify { publishing_entry }
    end
  end
end

# == Schema Information
#
# Table name: entries
#
#  actuality_expired_at :datetime
#  annotation           :text
#  author               :string(255)
#  body                 :text
#  created_at           :datetime         not null
#  delete_at            :datetime
#  deleted_by_id        :integer
#  id                   :integer          not null, primary key
#  initiator_id         :integer
#  legacy_id            :integer
#  locked_at            :datetime
#  locked_by_id         :integer
#  since                :datetime
#  slug                 :string(255)
#  source               :string(255)
#  source_link          :string(255)
#  state                :string(255)
#  title                :text
#  type                 :string(255)
#  updated_at           :datetime         not null
#  vfs_path             :string(255)
#

