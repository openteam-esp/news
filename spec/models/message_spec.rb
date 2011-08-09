# encoding: utf-8

require 'spec_helper'

describe Message do
  before do
    corrector_role = Fabricate(:role, :kind => 'corrector')
    publisher_role = Fabricate(:role, :kind => 'publisher')
    @initiator = Fabricate(:user)
    @corrector = Fabricate(:user)
    @corrector.roles << corrector_role
    @publisher = Fabricate(:user)
    @publisher.roles << publisher_role
    @corrpub   = Fabricate(:user)
    @corrpub.roles << corrector_role
    @corrpub.roles << publisher_role
  end
  it 'после создания новости, сообщение получит только инициатор' do
    expect {Fabricate(:entry, :user_id => @initiator)}.to change{@initiator.messages.count}.by(1)
  end

  it 'после отправки корректору, сообщение получат пользователи с ролью корректора, корр+публ и инициатор' do
    entry = Fabricate(:entry, :user_id => @initiator)
    entry.events.create(:kind => 'send_to_corrector', :user_id => @initiator)

    @initiator.messages.count.should eql 2
    @corrector.messages.count.should eql 1
    @publisher.messages.count.should eql 0
    @corrpub.messages.count.should eql 1
  end

  it 'после возврата автору, сообщение получат пользователи с ролью корректора, корр+публ и иницатор' do
    entry = Fabricate(:entry, :user_id => @initiator.id)
    entry.events.create(:kind => 'send_to_corrector', :user_id => @initiator.id)
    entry.events.create(:kind => 'return_to_author', :user_id => @corrector.id)

    @initiator.messages.count.should eql 3
    @corrector.messages.count.should eql 2
    @publisher.messages.count.should eql 0
    @corrpub.messages.count.should eql 2
  end

  it 'после взятия на корректуру, сообщение получат пользователи с ролью корректора, корр+публ и иницатор' do
    entry = Fabricate(:entry, :user_id => @initiator.id)
    entry.events.create(:kind => 'send_to_corrector', :user_id => @initiator.id)
    entry.events.create(:kind => 'correct', :user_id => @corrector.id)

    @initiator.messages.count.should eql 3
    @corrector.messages.count.should eql 2
    @publisher.messages.count.should eql 0
    @corrpub.messages.count.should eql 2
  end

  it 'после отправки публикатору, сообщение получат пользователи с ролью корректора, публикатора,корр+публ и иницатор' do
    entry = Fabricate(:entry, :user_id => @initiator.id)
    entry.events.create(:kind => 'send_to_corrector', :user_id => @initiator.id)
    entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)

    @initiator.messages.count.should eql 4
    @corrector.messages.count.should eql 3
    @publisher.messages.count.should eql 1
    @corrpub.messages.count.should eql 3
  end

  it 'после возврата корректору, сообщение получат пользователи с ролью корректора, публикатор, корр+публ и иницатор' do
    entry = Fabricate(:entry, :user_id => @initiator.id)
    entry.events.create(:kind => 'send_to_corrector', :user_id => @initiator.id)
    entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)
    entry.events.create(:kind => 'return_to_corrector', :user_id => @publisher.id)

    @initiator.messages.count.should eql 5
    @corrector.messages.count.should eql 4
    @publisher.messages.count.should eql 2
    @corrpub.messages.count.should eql 4
  end

  it 'после публикации, сообщение получат пользователи с ролью публикатора, корр+публ, иницатор и пользователи которые имею отношение к новости' do
    entry = Fabricate(:entry, :user_id => @initiator.id)
    entry.events.create(:kind => 'send_to_corrector', :user_id => @initiator.id)
    entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)
    entry.events.create(:kind => 'publish', :user_id => @publisher.id)

    @initiator.messages.count.should eql 5
    @corrector.messages.count.should eql 4
    @publisher.messages.count.should eql 2
    @corrpub.messages.count.should eql 4
  end

  it 'после немедленной отправки публикатору, сообщение получат пользователи с ролью корр+публ, публикатора' do
    entry = Fabricate(:entry, :user_id => @corrpub.id)
    entry.events.create(:kind => 'immediately_send_to_publisher', :user_id => @corrpub.id)

    @initiator.messages.count.should eql 0
    @corrector.messages.count.should eql 0
    @publisher.messages.count.should eql 1
    @corrpub.messages.count.should eql 2
  end

  it 'после немедленной публикации, сообщение получат пользователи с ролью корр+публ, публикатора' do
    entry = Fabricate(:entry, :user_id => @corrpub.id)
    entry.events.create(:kind => 'immediately_publish', :user_id => @corrpub.id)

    @initiator.messages.count.should eql 0
    @corrector.messages.count.should eql 0
    @publisher.messages.count.should eql 1
    @corrpub.messages.count.should eql 2
  end

  it 'после отправки в корзину, сообщение получат пользователи имеющие отношение к новости' do
    entry = Fabricate(:entry, :user_id => @initiator.id)
    entry.events.create(:kind => 'send_to_corrector', :user_id => @initiator.id)
    entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)
    entry.events.create(:kind => 'publish', :user_id => @publisher.id)
    entry.events.create(:kind => 'to_trash', :user_id => @publisher.id)


    @initiator.messages.count.should eql 6
    @corrector.messages.count.should eql 5
    @publisher.messages.count.should eql 3
    @corrpub.messages.count.should eql 4
  end

  it 'после восстановления из корзины, сообщение получат пользователи имеющие отношение к новости' do
    entry = Fabricate(:entry, :user_id => @initiator.id)
    entry.events.create(:kind => 'send_to_corrector', :user_id => @initiator.id)
    entry.events.create(:kind => 'correct', :user_id => @corrector.id)
    entry.events.create(:kind => 'send_to_publisher', :user_id => @corrector.id)
    entry.events.create(:kind => 'publish', :user_id => @publisher.id)
    entry.events.create(:kind => 'to_trash', :user_id => @publisher.id)
    entry.events.create(:kind => 'restore', :user_id => @corrector.id)


    @initiator.messages.count.should eql 7
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

