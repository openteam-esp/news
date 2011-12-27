# encoding: utf-8

require 'spec_helper'

describe Event do

  before(:each) do
    set_current_user(initiator)
  end

  it { should belong_to :entry }
  it { should belong_to :user }
  it { should belong_to :task }

  describe "должен создаваться" do
    def updated_entry(options={})
      @updated_entry ||= draft.tap do | entry |
                            as initiator do
                              if options[:channels]
                                entry.channels << channel
                              end
                              entry.update_attributes :author => Ryba::Name.full_name
                              entry.prepare.complete!
                            end
                          end
    end

    it "при создании новости" do
      draft.events.map(&:event).should == ['accept']
    end

    describe "при закрытии задачи" do
      def last_event(options={})
        @last_event ||= updated_entry(options).events(true).first
      end

      it { updated_entry.events.should have(2).items }
      it { last_event.user.should == initiator }
      it { last_event.event.should == 'complete' }
      it { last_event.versioned_entry.author.should == updated_entry.author }
      it { last_event(:channels => true).versioned_entry.channel_ids.should == updated_entry.channel_ids }
    end
  end

  if(false)

  describe "сохраняемые версии новости" do
    it "event не должен создаваться после сохранения новости" do
      expect {entry.update_attribute :title, "title"}.to_not change(Event, :count)
    end

    it "должен сохранять каналы" do
      channels = [Fabricate(:channel), Fabricate(:channel)]
      channel_ids = channels.map(&:id)
      entry.events.create(:kind => :store, :entry_attributes => entry.attributes.merge(:channel_ids => channel_ids))
      channels.last.destroy
      entry.events.last.versioned_entry.channels.should == channels
    end

  end

  describe "отмена изменений" do
    it "когда была пустая новость" do
      channel_ids = [Fabricate(:channel).id]
      entry.update_attributes(:title => "title", :channel_ids => channel_ids)
      entry.events.create(:kind => :restore)
      restore_entry_version = entry.events.first.versioned_entry
      restore_entry_version.title.should == "title"
      restore_entry_version.channel_ids.should == channel_ids
      entry.reload
      entry.title.should be_nil
      entry.channel_ids.should == []
      entry.image_ids.should == []
    end

    it "уже были события" do
      set_current_user initiator
      channels = [Fabricate(:channel), Fabricate(:channel)]
      awaiting_correction_entry(:title => "title", :channel_ids => channels.map(&:id))
      awaiting_correction_entry.channels.last.destroy
      awaiting_correction_entry.update_attributes(:title => "new title")
      awaiting_correction_entry.events.create!(:kind => :restore)
      restored_entry = awaiting_correction_entry.events.first.versioned_entry
      restored_entry.channels.should == [channels.first]
      restored_entry.title.should == "new title"
      awaiting_correction_entry.reload

      awaiting_correction_entry.title.should == "title"
      awaiting_correction_entry.channels.should == [channels.first]
    end
  end

  describe "полномочия действий" do
    let(:ability) { Ability.new }
    describe "инициатора" do
      before(:each) do
        set_current_user initiator
      end
      it { ability.should be_able_to :create, stored_draft.events.build(:kind => :store) }
    end

    describe "другой инициатор" do
      before(:each) do
        set_current_user another_initiator
      end
      it { ability.should_not be_able_to :create, stored_draft.events.build(:kind => :store) }
    end
  end

  describe "должен сохранять entry" do
    it "должен сохранять каналы" do
      channel_ids = [Fabricate(:channel), Fabricate(:channel)].map(&:id)
      entry.events.create(:kind => :store, :entry_attributes => entry.attributes.merge(:channel_ids => channel_ids))
      entry.reload.channel_ids.should == channel_ids
    end
  end

  end
end




# == Schema Information
#
# Table name: events
#
#  id               :integer         not null, primary key
#  event            :string(255)
#  text             :text
#  entry_id         :integer
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  serialized_entry :text
#  task_id          :integer
#

