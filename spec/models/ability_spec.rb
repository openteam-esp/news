# encoding: utf-8

require 'spec_helper'

describe Ability, 'возможность' do

  shared_examples_for 'can create news' do
    before { channel }
    it { should     be_able_to(:create, NewsEntry.new) }
  end
  shared_examples_for 'can not create news' do
    before { channel }
    it { should_not be_able_to(:create, NewsEntry.new) }
  end
  shared_examples_for 'can do nothing' do | entry_name |
    let(:entry) { send(entry_name) }
    it { should_not be_able_to(:read, entry) }
    it { should_not be_able_to(:update, entry) }
    it { should_not be_able_to(:destroy, entry) }
  end
  shared_examples_for 'can only read' do | entry_name |
    let(:entry) { send(entry_name) }
    it { should     be_able_to(:read, entry) }
    it { should_not be_able_to(:update, entry) }
    it { should_not be_able_to(:destroy, entry) }
  end
  shared_examples_for 'can do anything' do | entry_name |
    let(:entry) { send(entry_name) }
    it { should     be_able_to(:read, entry) }
    it { should     be_able_to(:update, entry) }
    it { should     be_able_to(:destroy, entry) }
  end
  context 'user' do
    subject { ability_for(user) }
    it_behaves_like 'can not create news'
    it_behaves_like 'can do nothing',  :draft
    it_behaves_like 'can do nothing',  :another_draft
    it_behaves_like 'can do nothing',  :fresh_correcting
    it_behaves_like 'can do nothing',  :another_fresh_correcting
    it_behaves_like 'can do nothing',  :processing_correcting
    it_behaves_like 'can do nothing',  :another_processing_correcting
    it_behaves_like 'can do nothing',  :fresh_publishing
    it_behaves_like 'can do nothing',  :another_fresh_publishing
    it_behaves_like 'can do nothing',  :processing_publishing
    it_behaves_like 'can do nothing',  :another_processing_publishing
    it_behaves_like 'can do nothing',  :published
    it_behaves_like 'can do nothing',  :another_published
  end
  context 'initiator' do
    subject { ability_for(initiator) }
    it_behaves_like 'can create news'
    it_behaves_like 'can do anything',  :draft
    it_behaves_like 'can do nothing',   :another_draft
    it_behaves_like 'can only read',    :fresh_correcting
    it_behaves_like 'can do nothing',   :another_fresh_correcting
    it_behaves_like 'can only read',    :processing_correcting
    it_behaves_like 'can do nothing',   :another_processing_correcting
    it_behaves_like 'can only read',    :fresh_publishing
    it_behaves_like 'can do nothing',   :another_fresh_publishing
    it_behaves_like 'can only read',    :processing_publishing
    it_behaves_like 'can do nothing',   :another_processing_publishing
    it_behaves_like 'can only read',    :published
    it_behaves_like 'can do nothing',   :another_published
  end
  context 'corrector' do
    subject { ability_for(corrector) }
    it_behaves_like 'can create news'
    it_behaves_like 'can do nothing',   :draft
    it_behaves_like 'can do nothing',   :another_draft
    it_behaves_like 'can only read',    :fresh_correcting
    it_behaves_like 'can only read',    :another_fresh_correcting
    it_behaves_like 'can do anything',  :processing_correcting
    it_behaves_like 'can only read',    :another_processing_correcting
    it_behaves_like 'can only read',    :fresh_publishing
    it_behaves_like 'can only read',    :another_fresh_publishing
    it_behaves_like 'can only read',    :processing_publishing
    it_behaves_like 'can only read',    :another_processing_publishing
    it_behaves_like 'can only read',    :published
    it_behaves_like 'can only read',    :another_published
  end
  context 'publisher' do
    subject { ability_for(publisher) }
    it_behaves_like 'can create news'
    it_behaves_like 'can do nothing',   :draft
    it_behaves_like 'can do nothing',   :another_draft
    it_behaves_like 'can only read',    :fresh_correcting
    it_behaves_like 'can only read',    :another_fresh_correcting
    it_behaves_like 'can only read',    :processing_correcting
    it_behaves_like 'can only read',    :another_processing_correcting
    it_behaves_like 'can only read',    :fresh_publishing
    it_behaves_like 'can only read',    :another_fresh_publishing
    it_behaves_like 'can do anything',  :processing_publishing
    it_behaves_like 'can only read',    :another_processing_publishing
    it_behaves_like 'can only read',    :published
    it_behaves_like 'can only read',    :another_published
  end



  context 'following' do
    context 'initiator' do
      it { ability_for(corrector).should_not be_able_to(:create, Following.new(:follower => another_corrector)) }
    end
    describe "создание" do
      it { ability_for(corrector).should_not be_able_to(:create, Following.new(:follower => another_corrector)) }
      it { ability_for(corrector).should be_able_to(:create, Following.new(:follower => corrector)) }
      it { ability_for(publisher).should be_able_to(:create, Following.new(:follower => publisher)) }
    end
    describe "удаление" do
      it { ability_for(corrector).should_not be_able_to(:destroy, Following.new(:follower => another_corrector)) }
      it { ability_for(corrector).should be_able_to(:destroy, Following.new(:follower => corrector)) }
      it { ability_for(publisher).should be_able_to(:destroy, Following.new(:follower => publisher)) }
    end
  end

  if false

  describe "на entries" do

    describe "locked entry" do
      before do
        as corrector do
          prepare_subtask_for(corrector).accept
          draft.lock
        end
      end
      it { ability_for(corrector).should be_able_to(:update, draft) }
      it { ability_for(corrector).should_not be_able_to(:destroy, draft) }
      it { ability_for(initiator).should_not be_able_to(:update, draft) }
      it { ability_for(initiator).should_not be_able_to(:destroy, draft) }
    end

    describe "unlock entry" do
      before do
        prepare_subtask_for(another_initiator)
        as another_initiator do draft.lock end
      end
      it { ability_for(initiator).should be_able_to(:unlock, draft) }
      it { ability_for(another_initiator).should be_able_to(:unlock, draft) }
      it { ability_for(corrector).should_not be_able_to(:unlock, draft) }
      it { ability_for(publisher).should_not be_able_to(:unlock, draft) }
    end

    describe "deleted entry" do
      let(:entry) {as publisher do processing_publishing.destroy end}
      it_behaves_like "все могут только просматривать"
    end

  end


  end
end
