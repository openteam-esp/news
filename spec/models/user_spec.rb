# encoding: utf-8

require 'spec_helper'

describe User do
  describe '- анонимный пользователь может' do
    it 'читать rss'
    it 'читать опубликованные новости'
  end

  describe '- обычный пользователь может' do
    before do
      @user = Fabricate(:user)
      @ability = Ability.new(@user)
      @draft = Fabricate(:entry, :user_id => @user.id)
    end

    it 'восстановить новость к которой он имеет отношение' do
      @draft.events.create(:type => 'to_trash', :user_id => @user.id)
      restore_event = @draft.events.new(:type => 'restore', :user_id => @user.id)
      @ability.should be_able_to(:create, restore_event)
    end

    it 'не может восстановить новость к которой не имеет отношения' do
      another_user = Fabricate(:user)
      another_user_ability = Ability.new(another_user)
      @draft.events.create(:type => 'to_trash', :user_id => @user.id)
      restore_event_from_another_user = @draft.events.new(:type => 'restore', :user_id => another_user.id)
      @draft.reload
      another_user_ability.should_not be_able_to(:create, restore_event_from_another_user)
    end

    it 'отправить только по следующим переходам' do
      @draft.state_events_for(@user).should eql [:send_to_corrector, :to_trash]
    end

    it 'отправить только свой черновик корректору' do
      send_to_corrector_event = @draft.events.new(:type => 'send_to_corrector')
      @ability.should be_able_to(:create, send_to_corrector_event)
    end

    it 'отправить только свой черновик в корзину' do
      to_trash_event = @draft.events.new(:type => 'to_trash')
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
      other_draft_event = other_draft.events.new(:type => 'send_to_corrector')
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
      other_draft_event = other_draft.events.new(:type => 'send_to_corrector')
      @ability.should_not be_able_to(:create, other_draft_event)
    end

    describe 'только свой черновик' do
      let :draft do Fabricate(:entry, :user_id => @corrector.id) end

      it 'отправить только по следующим переходам' do
        draft.state_events_for(@corrector).should eql [:immediately_send_to_publisher, :to_trash]
      end

      it 'отправить в корзину' do
        to_trash_event = draft.events.new(:type => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'отправить публикатору' do
        send_publisher_event = draft.events.new(:type => 'immediately_send_to_publisher')
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
        entry = Fabricate(:entry)
        entry.events.create(:type => 'send_to_corrector')
        entry
      end

      it 'отправить только по следующим переходам' do
        awaiting_correction_entry.state_events_for(@corrector).should eql [:correct, :return_to_author, :to_trash]
      end

      it 'вернуть инициатору' do
        return_to_author_event = awaiting_correction_entry.events.new(:type => 'return_to_author')
        @ability.should be_able_to(:create, return_to_author_event)
      end

      it 'взять на корректировку' do
        correct_event = awaiting_correction_entry.events.new(:type => 'correct')
        @ability.should be_able_to(:create, correct_event)
      end

      it 'отправить в корзину' do
         to_trash_event = awaiting_correction_entry.events.new(:type => 'to_trash')
         @ability.should be_able_to(:create, to_trash_event)
      end
    end

    describe 'корректируемую новость' do
      let :correcting_entry do
        entry = Fabricate(:entry)
        entry.events.create(:type => 'send_to_corrector')
        entry.events.create(:type => 'correct')
        entry
      end

      it 'отправить только по следующим переходам' do
        correcting_entry.state_events_for(@corrector).should eql [:send_to_publisher, :to_trash]
      end

      it 'отправить в корзину' do
        to_trash_event = correcting_entry.events.new(:type => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'отправить публикатору' do
        send_publisher_event = correcting_entry.events.new(:type => 'send_to_publisher')
        @ability.should be_able_to(:create, send_publisher_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, correcting_entry)
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
        to_trash_event = draft.events.new(:type => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'отправить корректору' do
        send_to_corrector_event = draft.events.new(:type => 'send_to_corrector')
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
        entry = Fabricate(:entry)
        entry.events.create(:type => 'send_to_corrector')
        entry.events.create(:type => 'correct')
        entry.events.create(:type => 'send_to_publisher')
        entry
      end

      it 'отправить только по следующим переходам' do
        awaiting_publication_entry.state_events_for(@publisher).should eql [:publish, :return_to_corrector, :to_trash]
      end

      it 'вернуть корректору' do
        return_to_corrector_event = awaiting_publication_entry.events.new(:type => 'return_to_corrector')
        @ability.should be_able_to(:create, return_to_corrector_event)
      end

      it 'опубликовать' do
        publish_event = awaiting_publication_entry.events.new(:type => 'publish')
        @ability.should be_able_to(:create, publish_event)
      end

      it 'отправить в корзину' do
        to_trash_event = awaiting_publication_entry.events.new(:type => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end
    end

    describe 'опубликованную новость' do
      let :published_entry do
        entry = Fabricate(:entry)
        entry.events.create(:type => 'send_to_corrector')
        entry.events.create(:type => 'correct')
        entry.events.create(:type => 'send_to_publisher')
        entry.events.create(:type => 'publish')
        entry
      end

      it 'отправить только по следующим переходам' do
        published_entry.state_events_for(@publisher).should eql [:return_to_corrector, :to_trash]
      end

      it 'вернуть корректору' do
        return_to_corrector_event = published_entry.events.new(:type => 'return_to_corrector')
        @ability.should be_able_to(:create, return_to_corrector_event)
      end

      it 'отправить в корзину' do
        to_trash_event = published_entry.events.new(:type => 'to_trash')
        @ability.should  be_able_to(:create, to_trash_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, published_entry)
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
        publish_event = draft.events.new(:type => 'immediately_publish')
        @ability.should be_able_to(:create, publish_event)
      end

      it 'отправить в корзину' do
        to_trash_event = draft.events.new(:type => 'to_trash')
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
        entry = Fabricate(:entry)
        entry.events.create(:type => 'send_to_corrector')
        entry
      end

      it 'отправить только по следующим переходам' do
        awaiting_correction_entry.state_events_for(@corpuber).should eql [:correct, :return_to_author, :to_trash]
      end

      it 'вернуть инициатору' do
        return_to_author_event =  awaiting_correction_entry.events.new(:type => 'return_to_author')
        @ability.should be_able_to(:create, return_to_author_event)
      end

      it 'взять на корректировку' do
        correct_event = awaiting_correction_entry.events.new(:type => 'correct')
        @ability.should be_able_to(:create, correct_event)
      end

      it 'отправить в корзину' do
        to_trash_event = awaiting_correction_entry.events.new(:type => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end
    end

    describe 'корректируемую новость' do
      let :correcting_entry do
        entry = Fabricate(:entry)
        entry.events.create(:type => 'send_to_corrector')
        entry.events.create(:type => 'correct')
        entry
      end

      it 'отправить только по следующим переходам' do
        correcting_entry.state_events_for(@corpuber).should eql [:publish, :to_trash]
      end

      it 'опубликовать' do
        publish_event = correcting_entry.events.new(:type => 'publish')
        @ability.should be_able_to(:create, publish_event)
      end

      it 'отправить в корзину' do
        to_trash_event = correcting_entry.events.new(:type => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, correcting_entry)
      end
    end

    describe 'новость ожидающую публикации' do
      let :awaiting_publication_entry do
        entry = Fabricate(:entry)
        entry.events.create(:type => 'send_to_corrector')
        entry.events.create(:type => 'correct')
        entry.events.create(:type => 'send_to_publisher')
        entry
      end

      it 'отправить только по следующим переходам' do
        awaiting_publication_entry.state_events_for(@corpuber).should eql [:publish, :return_to_corrector, :to_trash]
      end

      it 'вернуть корректору' do
        return_to_corrector_event = awaiting_publication_entry.events.new(:type => 'return_to_corrector')
        @ability.should be_able_to(:create, return_to_corrector_event)
      end

      it 'опубликовать' do
        publish_event = awaiting_publication_entry.events.new(:type => 'publish')
        @ability.should be_able_to(:create, publish_event)
      end

      it 'отправить в корзину' do
        to_trash_event = awaiting_publication_entry.events.new(:type => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, awaiting_publication_entry)
      end
    end

    describe 'опубликованную новость' do
      let :published_entry do
        entry = Fabricate(:entry)
        entry.events.create(:type => 'send_to_corrector')
        entry.events.create(:type => 'correct')
        entry.events.create(:type => 'send_to_publisher')
        entry.events.create(:type => 'publish')
        entry
      end

      it 'отправить только по следующим переходам' do
        published_entry.state_events_for(@corpuber).should eql [:return_to_corrector, :to_trash]
      end

      it 'вернуть корректору' do
        return_to_corrector_event = published_entry.events.new(:type => 'return_to_corrector')
        @ability.should be_able_to(:create, return_to_corrector_event)
      end

      it 'отправить в корзину' do
        to_trash_event = published_entry.events.new(:type => 'to_trash')
        @ability.should be_able_to(:create, to_trash_event)
      end

      it 'редактировать' do
        @ability.should be_able_to(:update, published_entry)
      end
    end
  end
end

