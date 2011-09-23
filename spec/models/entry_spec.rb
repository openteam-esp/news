# encoding: utf-8

require 'spec_helper'

describe Entry do

  it { should have_many(:assets) }
  it { should have_many(:images) }
  it { should have_many(:videos) }
  it { should have_many(:audios) }
  it { should have_many(:attachments) }
  it { should have_many(:tasks).dependent(:destroy) }

  it { Entry.scoped.to_sql.should =~ /WHERE entries.deleted_at IS NULL ORDER BY id desc$/ }

  it 'должна корректно сохранять и отображать дату' do
    I18n.l(draft(:since => "19.07.2011 09:20").since, :format => :datetime).should == "19.07.2011 09:20"
  end

  describe "папки новостей" do
    it "инициатору показываются только его новости" do
      set_current_user(initiator)
      Entry.all_states.each do |state|
        Entry.state(state).where_values_hash.should == {:state => state, :initiator_id => initiator.id, 'deleted_at' => nil}
      end
    end

    describe "личные папки" do
      it "корректора" do
        set_current_user(initiator(:roles => :corrector))
        Entry.state(:draft).where_values_hash.should == {:state => :draft, :initiator_id => initiator.id, 'deleted_at' => nil}
      end
      it "публикатора" do
        set_current_user(initiator(:roles => :publisher))
        Entry.state(:draft).where_values_hash.should == {:state => :draft, :initiator_id => initiator.id, 'deleted_at' => nil}
      end
    end

    describe "папки для новостей в процесса" do
      it "корректора" do
        set_current_user(initiator(:roles => :corrector))
        Entry.state('processing').where_values_hash.should == {:state => Entry.processing_states, 'deleted_at' => nil}
      end
      it "публикатора" do
        set_current_user(initiator(:roles => :publisher))
        Entry.state('processing').where_values_hash.should == {:state => Entry.processing_states, 'deleted_at' => nil}
      end
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

end











# == Schema Information
#
# Table name: entries
#
#  id           :integer         not null, primary key
#  title        :text
#  annotation   :text
#  body         :text
#  since        :datetime
#  until        :datetime
#  state        :string(255)
#  author       :string(255)
#  initiator_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#  legacy_id    :integer
#  locked_at    :datetime
#  locked_by_id :integer
#  deleted_at   :datetime
#

