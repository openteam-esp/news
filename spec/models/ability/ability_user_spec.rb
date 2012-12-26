# encoding: utf-8

require 'spec_helper'
require File.expand_path('../ability_shared_examples', __FILE__)

describe Ability do
  include AbilitySharedExamples
  context 'user' do
    subject { ability_for(user) }
    it_behaves_like 'can not create news'
    it_behaves_like 'can do nothing',  :draft
    it_behaves_like 'can do nothing with processed news'
    it_behaves_like 'can not create channels'
  end
end
