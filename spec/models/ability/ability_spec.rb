# encoding: utf-8

require 'spec_helper'

describe Ability do
  shared_examples_for 'can create news' do
    it { should     be_able_to(:create, NewsEntry.new) }
  end
  shared_examples_for 'can not create news' do
    it { should_not be_able_to(:create, NewsEntry.new) }
  end
  shared_examples_for 'can do nothing' do |entry_name|
    let(:entry) { send(entry_name) }
    it { should_not be_able_to(:read, entry) }
    it { should_not be_able_to(:update, entry) }
    it { should_not be_able_to(:destroy, entry) }
  end
  shared_examples_for 'can only read' do |entry_name|
    let(:entry) { send(entry_name) }
    it { should     be_able_to(:read, entry) }
    it { should_not be_able_to(:update, entry) }
    it { should_not be_able_to(:destroy, entry) }
  end
  shared_examples_for 'can do anything' do |entry_name|
    let(:entry) { send(entry_name) }
    it { should     be_able_to(:read, entry) }
    it { should     be_able_to(:update, entry) }
    it { should     be_able_to(:destroy, entry) }
  end
  shared_examples_for 'can do nothing with processed news' do
    it_behaves_like 'can do nothing',  :fresh_correcting
    it_behaves_like 'can do nothing',  :processing_correcting
    it_behaves_like 'can do nothing',  :fresh_publishing
    it_behaves_like 'can do nothing',  :processing_publishing
    it_behaves_like 'can do nothing',  :published
  end
  shared_examples_for 'can only read processed news' do
    it_behaves_like 'can only read',  :fresh_correcting
    it_behaves_like 'can only read',  :processing_correcting
    it_behaves_like 'can only read',  :fresh_publishing
    it_behaves_like 'can only read',  :processing_publishing
    it_behaves_like 'can only read',  :published
  end

  context 'user' do
    subject { ability_for(user) }
    it_behaves_like 'can not create news'
    it_behaves_like 'can do nothing',  :draft
    it_behaves_like 'can do nothing with processed news'
  end
  context 'initiator' do
    context 'of channel' do
      subject { ability_for(initiator_of(channel)) }
      it_behaves_like 'can create news'
      it_behaves_like 'can do anything',  :draft
      it_behaves_like 'can only read processed news'
    end
    context 'of another channel' do
      subject { ability_for(initiator_of(another_channel)) }
      it_behaves_like 'can not create news'
      it_behaves_like 'can do nothing with processed news'
    end
    context '(second) of channlel' do
      subject { ability_for(another_initiator_of(channel)) }
      it_behaves_like 'can create news'
      it_behaves_like 'can do nothing with processed news'
    end
  end
  context 'corrector' do
    context 'of channel' do
      subject { ability_for(corrector_of(channel)) }
      it_behaves_like 'can create news'
      it_behaves_like 'can do nothing',   :draft
      it_behaves_like 'can only read',    :fresh_correcting
      it_behaves_like 'can do anything',  :processing_correcting
      it_behaves_like 'can only read',    :fresh_publishing
      it_behaves_like 'can only read',    :processing_publishing
      it_behaves_like 'can only read',    :published
    end
    context 'of another channel' do
      subject { ability_for(corrector_of(another_channel)) }
      it_behaves_like 'can not create news'
      it_behaves_like 'can do nothing',   :draft
      it_behaves_like 'can only read processed news'
    end
    context '(second) of channel' do
      subject { ability_for(another_corrector_of(channel)) }
      it_behaves_like 'can create news'
      it_behaves_like 'can do nothing',   :draft
      it_behaves_like 'can only read processed news'
    end
  end
  context 'publisher' do
    context 'of channel' do
      subject { ability_for(publisher_of(channel)) }
      it_behaves_like 'can create news'
      it_behaves_like 'can do nothing',   :draft
      it_behaves_like 'can only read',    :fresh_correcting
      it_behaves_like 'can only read',    :processing_correcting
      it_behaves_like 'can only read',    :fresh_publishing
      it_behaves_like 'can do anything',  :processing_publishing
      it_behaves_like 'can only read',    :published
    end
    context 'of another channel' do
      subject { ability_for(publisher_of(another_channel)) }
      it_behaves_like 'can not create news'
      it_behaves_like 'can do nothing',   :draft
      it_behaves_like 'can only read processed news'
    end
    context '(second) of channel' do
      subject { ability_for(another_publisher_of(channel)) }
      it_behaves_like 'can create news'
      it_behaves_like 'can do nothing',   :draft
      it_behaves_like 'can only read processed news'
    end
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
end
