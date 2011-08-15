# encoding: utf-8

require 'spec_helper'

describe Event do
  before do
    @initiator  = Fabricate(:user)
    @subscriber = Fabricate(:user)
    @corrector_role = Fabricate(:role, :kind => 'corrector')
    @publisher_role = Fabricate(:role, :kind => 'publisher')
    Fabricate(:folder, :title => :draft)
    Fabricate(:folder, :title => :awaiting_correction)
    @entry = Fabricate(:entry, :user_id => @initiator.id)
  end

  it "после создания события с типом send_to_corrector - новость должны иметь соответствующий статус" do
    @entry.events.create!(:kind => :send_to_corrector, :text => 'опубликуйте, пжалтеста, а?')
    @entry.reload.should be_awaiting_correction
  end

  it 'после создания события с типом create, инициатор должен иметь подписку на созданную новость' do
    @initiator.subscribes.should be_one
  end

  describe 'после создания должна получить список подписчиков' do
    it 'для подписавшихся на новости инициатора' do
      subscribe = Fabricate(:subscribe, :subscriber => @subscriber, :initiator => @initiator)
      @entry.events.last.subscribers.should include @subscriber
    end

    it 'для подписавшихся на события новости ' do
      subscribe = Fabricate(:subscribe, :subscriber => @subscriber, :entry => @entry)
      @entry.events.create!(:kind => :send_to_corrector)
      @entry.events.first.subscribers.should include @subscriber
    end

    it 'по типу события, получаем всех пользователей с определенными ролями' do
      corrector = Fabricate(:user)
      corrector.roles << @corrector_role
      @entry.events.create!(:kind => :send_to_corrector)
      @entry.events.first.subscribers.should include corrector
    end
  end

  it 'после создания события, создать сообщения для подписчиков'
  #do
    #subscribe = Fabricate(:subscribe, :subscriber => @subscriber, :initiator => @initiator)
    #expect { Fabricate(:entry, :user_id => @initiator.id) }.to change{@subscriber.messages.reload.count}.by(1)
  #end

end



# == Schema Information
#
# Table name: events
#
#  id         :integer         not null, primary key
#  kind       :string(255)
#  text       :text
#  entry_id   :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  version_id :integer
#

