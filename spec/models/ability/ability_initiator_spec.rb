# encoding: utf-8

require 'spec_helper'
require File.expand_path('../ability_shared_examples', __FILE__)

describe Ability do
  include AbilitySharedExamples
  context 'initiator' do
    context 'of channel' do
      subject { ability_for(initiator_of(channel)) }
      it_behaves_like 'can create news'
      it_behaves_like 'can do anything',  :draft
      it_behaves_like 'can only read processed news'
      it_behaves_like 'can not create channels'
    end
    context '(second) of channlel' do
      subject { ability_for(another_initiator_of(channel)) }
      it_behaves_like 'can create news'
      it_behaves_like 'can do nothing with processed news'
    end
    context 'of another channel' do
      subject { ability_for(initiator_of(another_channel)) }
      it_behaves_like 'can not create news'
      it_behaves_like 'can do nothing with processed news'
    end
  end
end
