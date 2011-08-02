# encoding: utf-8

require 'spec_helper'

describe User do
  describe '- обычный пользователь может' do
    before do
      @user = Fabricate(:user)
      @ability = Ability.new(@user)
      @draft = Fabricate(:entry, :user_id => @user.id)
    end

    it 'восстановить новость к которой он имеет отношение' do
      @draft.events.create(:kind => 'to_trash', :user_id => @user.id)
      restore_event = @draft.events.new(:kind => 'restore', :user_id => @user.id)
      @ability.should be_able_to(:create, restore_event)
    end

    it 'не может восстановить новость к которой не имеет отношения' do
      another_user = Fabricate(:user)
      another_user_ability = Ability.new(another_user)
      @draft.events.create(:kind => 'to_trash', :user_id => @user.id)
      restore_event_from_another_user = @draft.events.new(:kind => 'restore', :user_id => another_user.id)
      @draft.reload
      another_user_ability.should_not be_able_to(:create, restore_event_from_another_user)
    end

    it 'отправить только по следующим переходам' do
      @draft.state_events_for(@user).should eql [:send_to_corrector, :to_trash]
    end

    it 'отправить только свой черновик корректору' do
      send_to_corrector_event = @draft.events.new(:kind => 'send_to_corrector')
      @ability.should be_able_to(:create, send_to_corrector_event)
    end

    it 'отправить только свой черновик в корзину' do
      to_trash_event = @draft.events.new(:kind => 'to_trash')
      @ability.should be_able_to(:create, to_trash_event)
    end

    it 'редактировать только свой черновик' do
      @ability.should be_able_to(:update, @draft)
    end

    it 'создать черновик' do
      @ability.should be_able_to(:create, Entry)
    end

    it 'выполнять действия только над своим черновиком' do
      other_user = Fabricate(:user)
      other_draft = Fabricate(:entry, :user_id => other_user.id)
      other_draft.state_events_for(@user).should be_empty
      other_draft_event = other_draft.events.new(:kind => 'send_to_corrector')
      @ability.should_not be_able_to(:create, other_draft_event)
    end
  end

  describe '- корректор может' do
    before do
      @corrector = Fabricate(:user, :roles => ['corrector'])
      @ability = Ability.new(@corrector)
    end

    it 'выполнять действия только над своим черновиком' do
      other_user = Fabricate(:user)
      other_draft = Fabricate(:entry, :user_id => other_user.id)
      other_draft.state_events_for(@corrector).should be_empty
      other_draft_event = other_draft.events.new(:kind => 'send_to_corrector')
      @ability.should_not be_able_to(:create, other_draft_event)
    end

    describe 'только свой черновик' do
      let :draft do Fabricate(:entry, :user_id => @corrector.id) end

      it 'отправить только по следующим переходам' do
        draft.state_events_for(@corrector).should eql [:immediately_send_to_publisher, :to_trash]
      end

      it 'отправить в корзину' do
        to_trash_event = draft.events.new(:kind => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'отправить публикатору' do
        send_publisher_event = draft.events.new(:kind => 'immediately_send_to_publisher')
        @ability.should be_able_to(:create, send_publisher_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, draft)
      end

      it 'создать' do
        @ability.should be_able_to(:create, Event)
      end
    end

    describe 'новость ожидающую корректировки' do
      let :awaiting_correction_entry do
        entry = Fabricate(:entry, :user_id => Fabricate(:user))
        entry.events.create(:kind => 'send_to_corrector')
        entry
      end

      it 'отправить только по следующим переходам' do
        awaiting_correction_entry.reload.state_events_for(@corrector).should eql [:correct, :return_to_author, :to_trash]
      end

      it 'вернуть инициатору' do
        return_to_author_event = awaiting_correction_entry.events.new(:kind => 'return_to_author')
        @ability.should be_able_to(:create, return_to_author_event)
      end

      it 'взять на корректировку' do
        correct_event = awaiting_correction_entry.events.new(:kind => 'correct')
        @ability.should be_able_to(:create, correct_event)
      end

      it 'отправить в корзину' do
         to_trash_event = awaiting_correction_entry.events.new(:kind => 'to_trash')
         @ability.should be_able_to(:create, to_trash_event)
      end
    end

    describe 'корректируемую новость' do
      let :correcting_entry do
        entry = Fabricate(:entry, :user_id => Fabricate(:user))
        entry.events.create(:kind => 'send_to_corrector')
        entry.events.create(:kind => 'correct')
        entry
      end

      it 'отправить только по следующим переходам' do
        correcting_entry.reload.state_events_for(@corrector).should eql [:send_to_publisher, :to_trash]
      end

      it 'отправить в корзину' do
        to_trash_event = correcting_entry.events.new(:kind => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'отправить публикатору' do
        send_publisher_event = correcting_entry.events.new(:kind => 'send_to_publisher')
        @ability.should be_able_to(:create, send_publisher_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, correcting_entry.reload)
      end
    end
  end

  describe '- публикатор может' do
    before do
      @publisher = Fabricate(:user, :roles => ['publisher'])
      @ability = Ability.new(@publisher)
    end

    describe 'только свой черновик' do
      let :draft do Fabricate(:entry, :user_id => @publisher.id) end

      it 'отправить только по следующим переходам' do
        draft.state_events_for(@publisher).should eql [:send_to_corrector, :to_trash]
      end

      it 'отправить в корзину' do
        to_trash_event = draft.events.new(:kind => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'отправить корректору' do
        send_to_corrector_event = draft.events.new(:kind => 'send_to_corrector')
        @ability.should be_able_to(:create, send_to_corrector_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, draft)
      end

      it 'создать' do
        @ability.should be_able_to(:create, Event)
      end
    end

    describe 'новость ожидающую публикации' do
      let :awaiting_publication_entry do
        entry = Fabricate(:entry, :user_id => Fabricate(:user))
        entry.events.create(:kind => 'send_to_corrector')
        entry.events.create(:kind => 'correct')
        entry.events.create(:kind => 'send_to_publisher')
        entry
      end

      it 'отправить только по следующим переходам' do
        awaiting_publication_entry.reload.state_events_for(@publisher).should eql [:publish, :return_to_corrector, :to_trash]
      end

      it 'вернуть корректору' do
        return_to_corrector_event = awaiting_publication_entry.events.new(:kind => 'return_to_corrector')
        @ability.should be_able_to(:create, return_to_corrector_event)
      end

      it 'опубликовать' do
        publish_event = awaiting_publication_entry.events.new(:kind => 'publish')
        @ability.should be_able_to(:create, publish_event)
      end

      it 'отправить в корзину' do
        to_trash_event = awaiting_publication_entry.events.new(:kind => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end
    end

    describe 'опубликованную новость' do
      let :published_entry do
        entry = Fabricate(:entry, :user_id => Fabricate(:user))
        entry.events.create(:kind => 'send_to_corrector')
        entry.events.create(:kind => 'correct')
        entry.events.create(:kind => 'send_to_publisher')
        entry.events.create!(:kind => 'publish')
        entry
      end

      it 'отправить только по следующим переходам' do
        published_entry.reload.state_events_for(@publisher).should eql [:return_to_corrector, :to_trash]
      end

      it 'вернуть корректору' do
        return_to_corrector_event = published_entry.events.new(:kind => 'return_to_corrector')
        @ability.should be_able_to(:create, return_to_corrector_event)
      end

      it 'отправить в корзину' do
        to_trash_event = published_entry.events.new(:kind => 'to_trash')
        @ability.should  be_able_to(:create, to_trash_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, published_entry.reload)
      end
    end
  end

  describe '- корректор+публикатор может' do
    before do
      @corpuber = Fabricate(:user, :roles => ['corrector','publisher'])
      @ability = Ability.new(@corpuber)
    end

    describe 'только свой черновик' do
      let :draft do Fabricate(:entry, :user_id => @corpuber.id) end

      it 'отправить только по следующим переходам' do
       draft.state_events_for(@corpuber).should eql [:immediately_publish, :to_trash]
      end

      it 'опубликовать' do
        publish_event = draft.events.new(:kind => 'immediately_publish')
        @ability.should be_able_to(:create, publish_event)
      end

      it 'отправить в корзину' do
        to_trash_event = draft.events.new(:kind => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, draft)
      end

      it 'создать' do
        @ability.should be_able_to(:create, Entry)
      end
    end

    describe 'новость ожидающую корректировки' do
      let :awaiting_correction_entry do
        entry = Fabricate(:entry, :user_id => Fabricate(:user))
        entry.events.create(:kind => 'send_to_corrector')
        entry
      end

      it 'отправить только по следующим переходам' do
        awaiting_correction_entry.reload.state_events_for(@corpuber).should eql [:correct, :return_to_author, :to_trash]
      end

      it 'вернуть инициатору' do
        return_to_author_event =  awaiting_correction_entry.events.new(:kind => 'return_to_author')
        @ability.should be_able_to(:create, return_to_author_event)
      end

      it 'взять на корректировку' do
        correct_event = awaiting_correction_entry.events.new(:kind => 'correct')
        @ability.should be_able_to(:create, correct_event)
      end

      it 'отправить в корзину' do
        to_trash_event = awaiting_correction_entry.events.new(:kind => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end
    end

    describe 'корректируемую новость' do
      let :correcting_entry do
        entry = Fabricate(:entry, :user_id => Fabricate(:user))
        entry.events.create(:kind => 'send_to_corrector')
        entry.events.create(:kind => 'correct')
        entry
      end

      it 'отправить только по следующим переходам' do
        correcting_entry.reload.state_events_for(@corpuber).should eql [:publish, :to_trash]
      end

      it 'опубликовать' do
        publish_event = correcting_entry.events.new(:kind => 'publish')
        @ability.should be_able_to(:create, publish_event)
      end

      it 'отправить в корзину' do
        to_trash_event = correcting_entry.events.new(:kind => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, correcting_entry.reload)
      end
    end

    describe 'новость ожидающую публикации' do
      let :awaiting_publication_entry do
        entry = Fabricate(:entry, :user_id => Fabricate(:user))
        entry.events.create(:kind => 'send_to_corrector')
        entry.events.create(:kind => 'correct')
        entry.events.create(:kind => 'send_to_publisher')
        entry
      end

      it 'отправить только по следующим переходам' do
        awaiting_publication_entry.reload.state_events_for(@corpuber).should eql [:publish, :return_to_corrector, :to_trash]
      end

      it 'вернуть корректору' do
        return_to_corrector_event = awaiting_publication_entry.events.new(:kind => 'return_to_corrector')
        @ability.should be_able_to(:create, return_to_corrector_event)
      end

      it 'опубликовать' do
        publish_event = awaiting_publication_entry.events.new(:kind => 'publish')
        @ability.should be_able_to(:create, publish_event)
      end

      it 'отправить в корзину' do
        to_trash_event = awaiting_publication_entry.events.new(:kind => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, awaiting_publication_entry.reload)
      end
    end

    describe 'опубликованную новость' do
      let :published_entry do
        entry = Fabricate(:entry, :user_id => Fabricate(:user))
        entry.events.create(:kind => 'send_to_corrector')
        entry.events.create(:kind => 'correct')
        entry.events.create(:kind => 'send_to_publisher')
        entry.events.create(:kind => 'publish')
        entry
      end

      it 'отправить только по следующим переходам' do
        published_entry.reload.state_events_for(@corpuber).should eql [:return_to_corrector, :to_trash]
      end

      it 'вернуть корректору' do
        return_to_corrector_event = published_entry.events.new(:kind => 'return_to_corrector')
        @ability.should be_able_to(:create, return_to_corrector_event)
      end

      it 'отправить в корзину' do
        to_trash_event = published_entry.events.new(:kind => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, published_entry.reload)
      end
    end
  end
end



# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  name                   :text
#  roles                  :text
#  email                  :string(255)
#  encrypted_password     :string(128)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#

