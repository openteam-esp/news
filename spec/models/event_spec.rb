# encoding: utf-8

require 'spec_helper'

describe Event do

  before(:each) do
    set_current_user(initiator)
  end

  describe "должен сохранять entry" do
    it "должен сохранять каналы" do
      channel_ids = [Fabricate(:channel), Fabricate(:channel)].map(&:id)
      draft_entry.events.create(:kind => :store, :entry_attributes => draft_entry.attributes.merge(:channel_ids => channel_ids))
      draft_entry.reload.channel_ids.should == channel_ids
    end
  end

  describe "сохраняемые версии новости" do
    it "event не должен создаваться после сохранения новости" do
      expect {draft_entry.update_attribute :title, "title"}.to_not change(Event, :count)
    end

    it "должны сохраняться images" do
      draft_entry_with_asset.events.create(:kind => :store)
      draft_entry_with_asset.events.last.versioned_entry.images.should == draft_entry_with_asset.images
    end

    it "должен сохранять каналы" do
      channels = [Fabricate(:channel), Fabricate(:channel)]
      channel_ids = channels.map(&:id)
      draft_entry.events.create(:kind => :store, :entry_attributes => draft_entry.attributes.merge(:channel_ids => channel_ids))
      channels.last.destroy
      draft_entry.events.last.versioned_entry.channels.should == channels
    end

  end

  describe "отмена изменений" do
    it "когда была пустая новость" do
      channel_ids = [Fabricate(:channel).id]
      draft_entry.update_attributes(:title => "title", :channel_ids => channel_ids)
      asset = Fabricate(:asset, :entry => draft_entry)
      draft_entry.events.create(:kind => :restore)
      restore_entry_version = draft_entry.events.first.versioned_entry
      restore_entry_version.title.should == "title"
      restore_entry_version.channel_ids.should == channel_ids
      restore_entry_version.image_ids.should == [asset.id]
      restore_entry_version.images.first.file_name.should_not be_nil
      draft_entry.reload
      draft_entry.title.should be_nil
      draft_entry.channel_ids.should == []
      draft_entry.image_ids.should == []
    end

    it "уже были события" do
      set_current_user initiator
      channels = [Fabricate(:channel), Fabricate(:channel)]
      awaiting_correction_entry(:title => "title", :channel_ids => channels.map(&:id), :asset_ids => [Fabricate(:asset).id])
      awaiting_correction_entry.assets.destroy_all
      Fabricate(:asset, :entry => awaiting_correction_entry, :file_mime_type => "video/ogg")
      awaiting_correction_entry.channels.last.destroy
      awaiting_correction_entry.update_attributes(:title => "new title")
      awaiting_correction_entry.events.create!(:kind => :restore)
      restored_entry = awaiting_correction_entry.events.first.versioned_entry
      restored_entry.images.should be_empty
      restored_entry.videos.should be_one
      restored_entry.channels.should == [channels.first]
      restored_entry.title.should == "new title"
      awaiting_correction_entry.reload

      awaiting_correction_entry.title.should == "title"
      awaiting_correction_entry.channels.should == [channels.first]
      awaiting_correction_entry.assets.should be_one
      awaiting_correction_entry.images.should be_one
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
  #it 'после создания события с типом create, инициатор должен иметь подписку на созданную новость' do
    #@initiator.subscribes.should be_one
  #end

  #describe 'после создания должна получить список подписчиков' do
    #it 'для подписавшихся на новости инициатора' do
      #subscribe = Fabricate(:subscribe, :subscriber => @subscriber, :initiator => @initiator)
      #@entry.events.last.subscribers.should include @subscriber
    #end

    #it 'для подписавшихся на события новости ' do
      #subscribe = Fabricate(:subscribe, :subscriber => @subscriber, :entry => @entry)
      #@entry.events.create!(:kind => :send_to_corrector)
      #@entry.events.first.subscribers.should include @subscriber
    #end

    #it 'по типу события, получаем всех пользователей с определенными ролями' do
      #corrector = Fabricate(:user)
      #corrector.roles << @corrector_role
      #@entry.events.create!(:kind => :send_to_corrector)
      #@entry.events.first.subscribers.should include corrector
    #end
  #end

  #it 'после создания события, создать сообщения для подписчиков'
  #do
    #subscribe = Fabricate(:subscribe, :subscriber => @subscriber, :initiator => @initiator)
    #set_current_user(@initiator)
    #expect { Fabricate(:entry) }.to change{@subscriber.messages.reload.count}.by(1)
  #end

end







# == Schema Information
#
# Table name: events
#
#  id               :integer         not null, primary key
#  kind             :string(255)
#  text             :text
#  entry_id         :integer
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#  serialized_entry :text
#

