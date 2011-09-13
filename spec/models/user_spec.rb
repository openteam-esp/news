# encoding: utf-8

require 'spec_helper'

describe User do
  describe "инициатор должен получить список" do
    before { set_current_user initiator }

    it "новых задач" do
      initiator.fresh_tasks.should be_empty
    end

    it "моих задач" do
      initiator.my_tasks.to_sql.should =~ /\(initiator_id = #{initiator.id} OR executor_id = #{initiator.id}\)/
      initiator.my_tasks.where_values_hash.should == {:state => :processing}
    end

    it "остальных задач" do
      initiator.other_tasks.should be_empty
    end
  end

  describe "корректор должен получить список" do
    before { set_current_user initiator(:roles => :corrector) }

    it "новых задач" do
      initiator.fresh_tasks.where_values_hash.should == {:state => :fresh, :type => ['Review']}
    end

    it "моих задач" do
      initiator.my_tasks.to_sql.should =~ /\(initiator_id = #{initiator.id} OR executor_id = #{initiator.id}\)/
      initiator.my_tasks.where_values_hash.should == {:state => :processing}
    end

    it "остальных задач" do
      initiator.other_tasks.to_sql.should =~ /initiator_id <> #{initiator.id}/
      initiator.other_tasks.to_sql.should =~ /executor_id <> #{initiator.id}/
      initiator.other_tasks.where_values_hash.should == { :state => :processing }
    end
  end

  describe "публикатор должен получить список" do
    before { set_current_user initiator(:roles => :publisher) }

    it "новых задач" do
      initiator.fresh_tasks.where_values_hash.should == {:state => :fresh, :type => ['Publish']}
    end

    it "моих задач" do
      initiator.my_tasks.to_sql.should =~ /\(initiator_id = #{initiator.id} OR executor_id = #{initiator.id}\)/
      initiator.my_tasks.where_values_hash.should == {:state => :processing}
    end

    it "остальных задач" do
      initiator.other_tasks.to_sql.should =~ /initiator_id <> #{initiator.id}/
      initiator.other_tasks.to_sql.should =~ /executor_id <> #{initiator.id}/
      initiator.other_tasks.where_values_hash.should == { :state => :processing }
    end
  end

  describe "корректор+публикатор должен получить список" do
    before { set_current_user initiator(:roles => [:publisher, :corrector]) }

    it "новых задач" do
      initiator.fresh_tasks.where_values_hash.should == {:state => :fresh, :type => ['Review', 'Publish']}
    end

    it "моих задач" do
      initiator.my_tasks.to_sql.should =~ /\(initiator_id = #{initiator.id} OR executor_id = #{initiator.id}\)/
      initiator.my_tasks.where_values_hash.should == {:state => :processing}
    end

    it "остальных задач" do
      initiator.other_tasks.to_sql.should =~ /initiator_id <> #{initiator.id}/
      initiator.other_tasks.to_sql.should =~ /executor_id <> #{initiator.id}/
      initiator.other_tasks.where_values_hash.should == { :state => :processing }
    end
  end

  #describe '- обычный пользователь может' do
    #before do
      #@user = Fabricate(:user)
      #User.current = @user
      #@ability = Ability.new(@user)
      #@draft = Fabricate(:entry)
    #end

    #it 'восстановить новость к которой он имеет отношение' do
      #@draft.events.create(:kind => 'discard', :user_id => @user.id)
      #recover_event = @draft.events.new(:kind => 'recover', :user_id => @user.id)
      #@ability.should be_able_to(:create, recover_event)
    #end

    #it 'не может восстановить новость к которой не имеет отношения' do
      #another_user = Fabricate(:user)
      #another_user_ability = Ability.new(another_user)
      #@draft.events.create(:kind => 'discard', :user_id => @user.id)
      #recover_event_from_another_user = @draft.events.new(:kind => 'recover', :user_id => another_user.id)
      #@draft.reload
      #another_user_ability.should_not be_able_to(:create, recover_event_from_another_user)
    #end

    #it 'отправить только по следующим переходам' do
      #@draft.state_events_for(@user).should eql [:send_to_corrector, :discard]
    #end

    #it 'отправить только свой черновик корректору' do
      #send_to_corrector_event = @draft.events.new(:kind => 'send_to_corrector')
      #@ability.should be_able_to(:create, send_to_corrector_event)
    #end

    #it 'отправить только свой черновик в корзину' do
      #discard_event = @draft.events.new(:kind => 'discard')
      #@ability.should be_able_to(:create, discard_event)
    #end

    #it 'редактировать только свой черновик' do
      #@ability.should be_able_to(:update, @draft)
    #end

    #it 'создать черновик' do
      #@ability.should be_able_to(:create, Entry)
    #end

    #it 'выполнять действия только над своим черновиком' do
      #other_user = Fabricate(:user)
      #User.current = other_user
      #other_draft = Fabricate(:entry)
      #other_draft.state_events_for(@user).should be_empty
      #other_draft_event = other_draft.events.new(:kind => 'send_to_corrector')
      #@ability.should_not be_able_to(:create, other_draft_event)
    #end
  #end

  #describe '- корректор может' do
    #before do
      #corrector_role = Fabricate(:role, :kind => 'corrector')
      #@corrector = Fabricate(:user)
      #@corrector.roles << corrector_role
      #@ability = Ability.new(@corrector)
    #end

    #it 'выполнять действия только над своим черновиком' do
      #other_user = Fabricate(:user)
      #User.current = other_user
      #other_draft = Fabricate(:entry)
      #other_draft.state_events_for(@corrector).should be_empty
      #other_draft_event = other_draft.events.new(:kind => 'send_to_corrector')
      #@ability.should_not be_able_to(:create, other_draft_event)
    #end

    #describe 'только свой черновик' do
      #def draft
        #@entry ||= begin
                      #User.current = @corrector
                      #Fabricate(:entry)
                   #end
      #end

      #it 'отправить только по следующим переходам' do
        #draft.state_events_for(@corrector).should eql [:immediately_send_to_publisher, :discard]
      #end

      #it 'отправить в корзину' do
        #discard_event = draft.events.new(:kind => 'discard')
        #@ability.should be_able_to(:create, discard_event)
      #end

      #it 'отправить публикатору' do
        #send_publisher_event = draft.events.new(:kind => 'immediately_send_to_publisher')
        #@ability.should be_able_to(:create, send_publisher_event)
      #end

      #it 'редактировать' do
        #@ability.should be_able_to(:update, draft)
      #end

      #it 'создать' do
        #@ability.should be_able_to(:create, Event)
      #end
    #end

    #describe 'новость ожидающую корректировки' do
      #def awaiting_correction_entry
        #@awaiting_correction_entry ||= begin
                                         #User.current = Fabricate(:user)
                                         #entry = Fabricate(:entry)
                                         #entry.events.create(:kind => 'send_to_corrector')
                                         #entry
                                       #end
      #end

      #it 'отправить только по следующим переходам' do
        #awaiting_correction_entry.reload.state_events_for(@corrector).should eql [:correct, :return_to_author, :discard]
      #end

      #it 'вернуть инициатору' do
        #return_to_author_event = awaiting_correction_entry.events.new(:kind => 'return_to_author')
        #@ability.should be_able_to(:create, return_to_author_event)
      #end

      #it 'взять на корректировку' do
        #correct_event = awaiting_correction_entry.events.new(:kind => 'correct')
        #@ability.should be_able_to(:create, correct_event)
      #end

      #it 'отправить в корзину' do
         #discard_event = awaiting_correction_entry.events.new(:kind => 'discard')
         #@ability.should be_able_to(:create, discard_event)
      #end
    #end

    #describe 'корректируемую новость' do
      #def correcting_entry
        #@correcting_entry ||= begin
                                #User.current = Fabricate(:user)
                                #entry = Fabricate(:entry)
                                #entry.events.create(:kind => 'send_to_corrector')
                                #entry.events.create(:kind => 'correct')
                                #entry
                              #end
      #end

      #it 'отправить только по следующим переходам' do
        #correcting_entry.reload.state_events_for(@corrector).should eql [:send_to_publisher, :discard]
      #end

      #it 'отправить в корзину' do
        #discard_event = correcting_entry.events.new(:kind => 'discard')
        #@ability.should be_able_to(:create, discard_event)
      #end

      #it 'отправить публикатору' do
        #send_publisher_event = correcting_entry.events.new(:kind => 'send_to_publisher')
        #@ability.should be_able_to(:create, send_publisher_event)
      #end

      #it 'редактировать' do
        #@ability.should be_able_to(:update, correcting_entry.reload)
      #end
    #end
  #end

  #describe '- публикатор может' do
    #before do
      #publisher_role = Fabricate(:role, :kind => 'publisher')
      #@publisher = Fabricate(:user)
      #@publisher.roles << publisher_role
      #@ability = Ability.new(@publisher)
    #end

    #describe 'только свой черновик' do
      #def draft
        #@draft ||= begin
                     #User.current = @publisher
                     #Fabricate(:entry)
                   #end
      #end

      #it 'отправить только по следующим переходам' do
        #draft.state_events_for(@publisher).should eql [:send_to_corrector, :discard]
      #end

      #it 'отправить в корзину' do
        #discard_event = draft.events.new(:kind => 'discard')
        #@ability.should be_able_to(:create, discard_event)
      #end

      #it 'отправить корректору' do
        #send_to_corrector_event = draft.events.new(:kind => 'send_to_corrector')
        #@ability.should be_able_to(:create, send_to_corrector_event)
      #end

      #it 'редактировать' do
        #@ability.should be_able_to(:update, draft)
      #end

      #it 'создать' do
        #@ability.should be_able_to(:create, Event)
      #end
    #end

    #describe 'новость ожидающую публикации' do
      #def awaiting_publication_entry
        #@awaiting_publication_entry ||= begin
                                          #User.current = Fabricate(:user)
                                          #entry = Fabricate(:entry)
                                          #entry.events.create(:kind => 'send_to_corrector')
                                          #entry.events.create(:kind => 'correct')
                                          #entry.events.create(:kind => 'send_to_publisher')
                                          #entry
                                        #end
      #end

      #it 'отправить только по следующим переходам' do
        #awaiting_publication_entry.reload.state_events_for(@publisher).should eql [:publish, :return_to_corrector, :discard]
      #end

      #it 'вернуть корректору' do
        #return_to_corrector_event = awaiting_publication_entry.events.new(:kind => 'return_to_corrector')
        #@ability.should be_able_to(:create, return_to_corrector_event)
      #end

      #it 'опубликовать' do
        #publish_event = awaiting_publication_entry.events.new(:kind => 'publish')
        #@ability.should be_able_to(:create, publish_event)
      #end

      #it 'отправить в корзину' do
        #discard_event = awaiting_publication_entry.events.new(:kind => 'discard')
        #@ability.should be_able_to(:create, discard_event)
      #end
    #end

    #describe 'опубликованную новость' do
      #def published_entry
        #@published_entry ||= begin
                               #User.current = Fabricate(:user)
                               #entry = Fabricate(:entry)
                               #entry.events.create(:kind => 'send_to_corrector')
                               #entry.events.create(:kind => 'correct')
                               #entry.events.create(:kind => 'send_to_publisher')
                               #entry.events.create!(:kind => 'publish')
                               #entry
                             #end
      #end

      #it 'отправить только по следующим переходам' do
        #published_entry.reload.state_events_for(@publisher).should eql [:return_to_corrector, :discard]
      #end

      #it 'вернуть корректору' do
        #return_to_corrector_event = published_entry.events.new(:kind => 'return_to_corrector')
        #@ability.should be_able_to(:create, return_to_corrector_event)
      #end

      #it 'отправить в корзину' do
        #discard_event = published_entry.events.new(:kind => 'discard')
        #@ability.should  be_able_to(:create, discard_event)
      #end

      #it 'редактировать' do
        #@ability.should be_able_to(:update, published_entry.reload)
      #end
    #end
  #end

  #describe '- корректор+публикатор может' do
    #before do
      #corrector_role = Fabricate(:role, :kind => 'corrector')
      #publisher_role = Fabricate(:role, :kind => 'publisher')
      #@corpuber = Fabricate(:user)
      #@corpuber.roles << corrector_role
      #@corpuber.roles << publisher_role
      #@ability = Ability.new(@corpuber)
    #end

    #describe 'только свой черновик' do
      #def draft
        #@draft ||= begin
                     #User.current = @corpuber
                     #Fabricate(:entry)
                   #end
      #end

      #it 'отправить только по следующим переходам' do
       #draft.state_events_for(@corpuber).should eql [:immediately_publish, :discard]
      #end

      #it 'опубликовать' do
        #publish_event = draft.events.new(:kind => 'immediately_publish')
        #@ability.should be_able_to(:create, publish_event)
      #end

      #it 'отправить в корзину' do
        #discard_event = draft.events.new(:kind => 'discard')
        #@ability.should be_able_to(:create, discard_event)
      #end

      #it 'редактировать' do
        #@ability.should be_able_to(:update, draft)
      #end

      #it 'создать' do
        #@ability.should be_able_to(:create, Entry)
      #end
    #end

    #describe 'новость ожидающую корректировки' do
       #def awaiting_correction_entry
         #@awaiting_correction_entry ||= begin
                                          #User.current = Fabricate(:user)
                                          #entry = Fabricate(:entry)
                                          #entry.events.create(:kind => 'send_to_corrector')
                                          #entry
                                        #end
      #end

      #it 'отправить только по следующим переходам' do
        #awaiting_correction_entry.reload.state_events_for(@corpuber).should eql [:correct, :return_to_author, :discard]
      #end

      #it 'вернуть инициатору' do
        #return_to_author_event =  awaiting_correction_entry.events.new(:kind => 'return_to_author')
        #@ability.should be_able_to(:create, return_to_author_event)
      #end

      #it 'взять на корректировку' do
        #correct_event = awaiting_correction_entry.events.new(:kind => 'correct')
        #@ability.should be_able_to(:create, correct_event)
      #end

      #it 'отправить в корзину' do
        #discard_event = awaiting_correction_entry.events.new(:kind => 'discard')
        #@ability.should be_able_to(:create, discard_event)
      #end
    #end

    #describe 'корректируемую новость' do
      #def correcting_entry
        #@correcting_entry ||= begin
                                #User.current = Fabricate(:user)
                                #entry = Fabricate(:entry)
                                #entry.events.create(:kind => 'send_to_corrector')
                                #entry.events.create(:kind => 'correct')
                                #entry
                              #end
      #end

      #it 'отправить только по следующим переходам' do
        #correcting_entry.reload.state_events_for(@corpuber).should eql [:publish, :discard]
      #end

      #it 'опубликовать' do
        #publish_event = correcting_entry.events.new(:kind => 'publish')
        #@ability.should be_able_to(:create, publish_event)
      #end

      #it 'отправить в корзину' do
        #discard_event = correcting_entry.events.new(:kind => 'discard')
        #@ability.should be_able_to(:create, discard_event)
      #end

      #it 'редактировать' do
        #@ability.should be_able_to(:update, correcting_entry.reload)
      #end
    #end

    #describe 'новость ожидающую публикации' do
      #def awaiting_publication_entry
        #@awaiting_publication_entry ||= begin
                                          #User.current ||= Fabricate(:user)
                                          #entry = Fabricate(:entry)
                                          #entry.events.create(:kind => 'send_to_corrector')
                                          #entry.events.create(:kind => 'correct')
                                          #entry.events.create(:kind => 'send_to_publisher')
                                          #entry
                                        #end
      #end

      #it 'отправить только по следующим переходам' do
        #awaiting_publication_entry.reload.state_events_for(@corpuber).should eql [:publish, :return_to_corrector, :discard]
      #end

      #it 'вернуть корректору' do
        #return_to_corrector_event = awaiting_publication_entry.events.new(:kind => 'return_to_corrector')
        #@ability.should be_able_to(:create, return_to_corrector_event)
      #end

      #it 'опубликовать' do
        #publish_event = awaiting_publication_entry.events.new(:kind => 'publish')
        #@ability.should be_able_to(:create, publish_event)
      #end

      #it 'отправить в корзину' do
        #discard_event = awaiting_publication_entry.events.new(:kind => 'discard')
        #@ability.should be_able_to(:create, discard_event)
      #end

      #it 'редактировать' do
        #@ability.should be_able_to(:update, awaiting_publication_entry.reload)
      #end
    #end

    #describe 'опубликованную новость' do
      #def published_entry
        #@published_entry ||= begin
                               #User.current = Fabricate(:user)
                               #entry = Fabricate(:entry)
                               #entry.events.create(:kind => 'send_to_corrector')
                               #entry.events.create(:kind => 'correct')
                               #entry.events.create(:kind => 'send_to_publisher')
                               #entry.events.create(:kind => 'publish')
                               #entry
                             #end
      #end

      #it 'отправить только по следующим переходам' do
        #published_entry.reload.state_events_for(@corpuber).should eql [:return_to_corrector, :discard]
      #end

      #it 'вернуть корректору' do
        #return_to_corrector_event = published_entry.events.new(:kind => 'return_to_corrector')
        #@ability.should be_able_to(:create, return_to_corrector_event)
      #end

      #it 'отправить в корзину' do
        #discard_event = published_entry.events.new(:kind => 'discard')
        #@ability.should be_able_to(:create, discard_event)
      #end

      #it 'редактировать' do
        #@ability.should be_able_to(:update, published_entry.reload)
      #end
    #end
  #end
end





# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  name                   :text
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
#  roles                  :text
#

