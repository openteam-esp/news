# encoding: utf-8

require 'spec_helper'
require File.expand_path('../ability_shared_examples', __FILE__)

describe Ability do
  include AbilitySharedExamples
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
    context '(second) of channel' do
      subject { ability_for(another_corrector_of(channel)) }
      it_behaves_like 'can create news'
      it_behaves_like 'can do nothing',   :draft
      it_behaves_like 'can only read processed news'
    end
    context 'of another channel' do
      subject { ability_for(corrector_of(another_channel)) }
      it_behaves_like 'can not create news'
      it_behaves_like 'can do nothing',  :draft
      it_behaves_like 'can do nothing with processed news'
      it_behaves_like 'can not create channels'
    end
  end
end
