# encoding: utf-8

require 'spec_helper'

describe User do
  let :user do Fabricate(:user) end

  let :entry do Fabricate(:entry) end
  let :awaiting_correction_entry do entry.send_to_corrector!; entry end
  let :returned_to_author_entry do awaiting_correction_entry.return_to_author!; entry end
  let :correcting_entry do awaiting_correction_entry.correct!; entry end
  let :awaiting_publication_entry do correcting_entry.send_to_publisher!; entry end
  let :published_entry do awaiting_publication_entry.publish!; entry end
  let :trash_entry do awaiting_publication_entry.to_trash!; entry end

  describe 'пользователь' do
    it 'может создавать новости' do
      ability = Ability.new(user)
      ability.should be_able_to(:create, Entry)
    end
  end

  describe 'доступные действия' do
    describe 'с новостью в состоянии' do
      before do
        @corrector = Fabricate(:user, :roles => ['corrector'], :email => 'corrector@mail.com')
        @publisher = Fabricate(:user, :roles => ['publisher'], :email => 'publisher@mail.com')
        @corrector_and_publisher = Fabricate(:user, :roles => ['corrector', 'publisher'], :email => 'cp@mail.com')
      end

      it 'draft' do
        entry.state_events_for_user(@corrector).should eql []
        entry.state_events_for_user(@publisher).should eql []
        entry.state_events_for_user(@corrector_and_publisher).should eql []
      end

      it 'awaiting_correction' do
        awaiting_correction_entry.state_events_for_user(@corrector).should eql [:correct, :return_to_author, :to_trash]
        awaiting_correction_entry.state_events_for_user(@publisher).should eql []
        awaiting_correction_entry.state_events_for_user(@corrector_and_publisher).should eql [:correct, :return_to_author, :to_trash]
      end

      it 'correcting' do
        correcting_entry.state_events_for_user(@corrector).should eql [:send_to_publisher]
        correcting_entry.state_events_for_user(@publisher).should eql []
        correcting_entry.state_events_for_user(@corrector_and_publisher).should eql [:send_to_publisher]
      end

      it 'awaiting_publication' do
        awaiting_publication_entry.state_events_for_user(@corrector).should eql []
        awaiting_publication_entry.state_events_for_user(@publisher).should eql [:publish, :return_to_corrector, :to_trash]
        awaiting_publication_entry.state_events_for_user(@corrector_and_publisher).should eql [:publish, :return_to_corrector, :to_trash]
      end

      it 'published' do
        published_entry.state_events_for_user(@corrector).should eql []
        published_entry.state_events_for_user(@publisher).should eql [:return_to_corrector]
        published_entry.state_events_for_user(@corrector_and_publisher).should eql [:return_to_corrector]
      end

      # TODO: разобраться с корзиной
    end
  end
end

