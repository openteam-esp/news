# encoding: utf-8

require 'spec_helper'
require File.expand_path('../ability_shared_examples', __FILE__)

describe Ability do
  include AbilitySharedExamples
  context 'following' do
    describe "создание" do
      subject { ability_for(corrector_of(channel)) }
      it { should_not be_able_to(:create, another_corrector_of(channel).followings.new) }
      it { should     be_able_to(:create, corrector_of(channel).followings.new) }
    end
    describe "удаление" do
      subject { ability_for(corrector_of(channel)) }
      it { should_not be_able_to(:destroy, another_corrector_of(channel).followings.new) }
      it { should     be_able_to(:destroy, corrector_of(channel).followings.new) }
    end
  end
end
