# encoding: utf-8

require 'spec_helper'

describe Message do
  before(:each) do
    corrector_role = Fabricate(:role, :kind => 'corrector')
    publisher_role = Fabricate(:role, :kind => 'publisher')
    @corrector = Fabricate(:user)
    @corrector.roles << corrector_role
    @publisher = Fabricate(:user)
    @publisher.roles << publisher_role
    @corrpub   = Fabricate(:user)
    @corrpub.roles << corrector_role
    @corrpub.roles << publisher_role
    User.current = initiator
    @entry = Fabricate(:entry)
  end

  it 'после создания новости никто не получит сообщение' do
    Delayed::Worker.new.work_off
    initiator.messages.count.should == 0
  end

  it 'после отправки корректору, сообщение получат пользователи с ролью корректора, корр+публ и инициатор' do
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_corrector', :user_id => initiator)
    Delayed::Worker.new.work_off

    initiator.messages.count.should eql 1
    @corrector.messages.count.should eql 1
    @publisher.messages.count.should eql 0
    @corrpub.messages.count.should eql 1
  end

  it 'после возврата автору, сообщение получат пользователи с ролью корректора, корр+публ и иницатор' do
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_corrector', :user_id => initiator.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'return_to_author', :user_id => @corrector.id)
    Delayed::Worker.new.work_off

    initiator.messages.count.should eql 2
    @corrector.messages.count.should eql 2
    @publisher.messages.count.should eql 0
    @corrpub.messages.count.should eql 2
  end

  it 'после взятия на корректуру, сообщение получат пользователи с ролью корректора, корр+публ и иницатор' do
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_corrector', :user_id => initiator.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    Delayed::Worker.new.work_off

    initiator.messages.count.should eql 2
    @corrector.messages.count.should eql 2
    @publisher.messages.count.should eql 0
    @corrpub.messages.count.should eql 2
  end

  it 'после отправки публикатору, сообщение получат пользователи с ролью корректора, публикатора,корр+публ и иницатор' do
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_corrector', :user_id => initiator.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)
    Delayed::Worker.new.work_off

    initiator.messages.count.should eql 3
    @corrector.messages.count.should eql 3
    @publisher.messages.count.should eql 1
    @corrpub.messages.count.should eql 3
  end

  it 'после возврата корректору, сообщение получат пользователи с ролью корректора, публикатор, корр+публ и иницатор' do
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_corrector', :user_id => initiator.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'return_to_corrector', :user_id => @publisher.id)
    Delayed::Worker.new.work_off

    initiator.messages.count.should eql 4
    @corrector.messages.count.should eql 4
    @publisher.messages.count.should eql 2
    @corrpub.messages.count.should eql 4
  end

  it 'после публикации, сообщение получат пользователи с ролью публикатора, корр+публ, иницатор и пользователи которые имею отношение к новости' do
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_corrector', :user_id => initiator.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'publish', :user_id => @publisher.id)
    Delayed::Worker.new.work_off

    initiator.messages.count.should eql 4
    @corrector.messages.count.should eql 4
    @publisher.messages.count.should eql 2
    @corrpub.messages.count.should eql 4
  end

  it 'после немедленной отправки публикатору, сообщение получат пользователи с ролью корр+публ, публикатора' do
    User.current = @corrpub
    other_entry = Fabricate(:entry)
    Delayed::Worker.new.work_off
    other_entry.events.create(:kind => 'immediately_send_to_publisher', :user_id => @corrpub.id)
    Delayed::Worker.new.work_off

    initiator.messages.count.should eql 0
    @corrector.messages.count.should eql 0
    @publisher.messages.count.should eql 1
    @corrpub.messages.count.should eql 1
  end

  it 'после немедленной публикации, сообщение получат пользователи с ролью корр+публ, публикатора' do
    User.current = @corrpub
    other_entry = Fabricate(:entry)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'immediately_publish', :user_id => @corrpub.id)
    Delayed::Worker.new.work_off

    initiator.messages.count.should eql 1
    @corrector.messages.count.should eql 0
    @publisher.messages.count.should eql 1
    @corrpub.messages.count.should eql 1
  end

  it 'после отправки в корзину, сообщение получат пользователи имеющие отношение к новости' do
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_corrector', :user_id => initiator.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'publish', :user_id => @publisher.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'to_trash', :user_id => @publisher.id)
    Delayed::Worker.new.work_off


    initiator.messages.count.should eql 5
    @corrector.messages.count.should eql 5
    @publisher.messages.count.should eql 3
    @corrpub.messages.count.should eql 4
  end

  it 'после восстановления из корзины, сообщение получат пользователи имеющие отношение к новости' do
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_corrector', :user_id => initiator.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'publish', :user_id => @publisher.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'to_trash', :user_id => @publisher.id)
    Delayed::Worker.new.work_off
    @entry.events.create(:kind => 'untrash', :user_id => @corrector.id)
    Delayed::Worker.new.work_off


    initiator.messages.count.should eql 6
    @corrector.messages.count.should eql 6
    @publisher.messages.count.should eql 4
    @corrpub.messages.count.should eql 4
  end
end

# == Schema Information
#
# Table name: messages
#
#  id         :integer         not null, primary key
#  event_id   :integer
#  user_id    :integer
#  text       :text
#  created_at :datetime
#  updated_at :datetime
#

