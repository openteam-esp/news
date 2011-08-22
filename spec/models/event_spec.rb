# encoding: utf-8

require 'spec_helper'

describe Event do

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
      restore_entry_version.images.first.file_file_name.should_not be_nil
      draft_entry.reload
      draft_entry.title.should be_nil
      draft_entry.channel_ids.should == []
      draft_entry.image_ids.should == []
    end
  end

  #before do
    #@initiator  = Fabricate(:user)
    #@subscriber = Fabricate(:user)
    #@corrector_role = Fabricate(:role, :kind => 'corrector')
    #@publisher_role = Fabricate(:role, :kind => 'publisher')
    #Fabricate(:folder, :title => :draft)
    #Fabricate(:folder, :title => :awaiting_correction)
    #set_current_user(@initiator)
    #@entry = Fabricate(:entry)
  #end

  #it "после создания события с типом send_to_corrector - новость должны иметь соответствующий статус" do
    #@entry.events.create!(:kind => :send_to_corrector, :text => 'опубликуйте, пжалтеста, а?')
    #@entry.reload.should be_awaiting_correction
  #end

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

