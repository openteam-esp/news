# encoding: utf-8

require 'spec_helper'

describe Event do
  before do
    @initiator  = Fabricate(:user)
    @subscriber = Fabricate(:user)
    @entry = Fabricate(:entry, :user_id => @initiator.id)
  end

  it "после создания события с типом send_to_corrector - новость должны иметь соответствующий статус" do
    @entry.events.create!(:kind => :send_to_corrector, :text => 'опубликуйте, пжалтеста, а?')
    @entry.reload.should be_awaiting_correction
  end

  describe 'после создания должна получить список подписчиков' do
    it 'для подписавшихся на новости инициатора' do
      subscribe = Fabricate(:subscribe, :subscriber => @subscriber, :initiator => @initiator)
      @entry.events.last.subscribers.should be_one
      @entry.events.last.subscribers.last.subscriber.should eql @subscriber
    end

    it 'для подписавшихся на события новости ' do
      subscribe = Fabricate(:subscribe, :subscriber => @subscriber, :entry => @entry)
      @entry.events.create!(:kind => :send_to_corrector)
      @entry.events.first.subscribers.should be_one
      @entry.events.first.subscribers.last.subscriber.should eql @subscriber
    end

    it 'для подписавшихся по типу события' do
      subscribe = Fabricate(:subscribe, :subscriber => @subscriber, :kind => :send_to_corrector)
      @entry.events.create!(:kind => :send_to_corrector)
      @entry.events.first.subscribers.should be_one
      @entry.events.first.subscribers.last.subscriber.should eql @subscriber
    end
  end

  it 'создать сообщения для подписчиков'

end

# == Schema Information
#
# Table name: events
#
#  id         :integer         not null, primary key
#  type       :string(255)
#  text       :text
#  entry_id   :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

