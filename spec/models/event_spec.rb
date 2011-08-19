# encoding: utf-8

require 'spec_helper'

describe Event do
  describe "сохраняемые версии новости" do
    it "должен сохраниться заголовок новости на текущий момент" do
      draft_entry.update_attribute :title, "title"
      draft_entry.events.last.versioned_entry.title.should == "title"
    end

    it "должны сохраняться images" do
      draft_entry.update_attribute :assets_attributes, [Fabricate.attributes_for(:asset)]
      draft_entry.events.last.versioned_entry.images.should == draft_entry.images
    end

    it "должен сохранять каналы" do
      draft_entry.channels << [Fabricate(:channel), Fabricate(:channel)]
      draft_entry.save
      draft_entry.events.last.versioned_entry.channels.should == draft_entry.channels
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
#  created_at       :datetime
#  updated_at       :datetime
#  serialized_entry :text
#  user_id          :integer
#

