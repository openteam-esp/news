# encoding: utf-8

require 'spec_helper'

describe Ability, 'возможность' do
  shared_examples_for 'prepare denied' do
    it { should_not be_able_to(:refuse,   draft.prepare) }
    it { should_not be_able_to(:refuse,   another_draft.prepare) }
    it { should_not be_able_to(:complete, draft.prepare) }
    it { should_not be_able_to(:complete, another_draft.prepare) }
    it { should_not be_able_to(:restore,  fresh_correcting.prepare) }
    it { should_not be_able_to(:restore,  another_fresh_correcting.prepare) }
  end

  shared_examples_for 'prepare allowed' do
    it { should     be_able_to(:refuse,   draft.prepare) }
    it { should_not be_able_to(:refuse,   another_draft.prepare) }
    it { should     be_able_to(:complete, draft.prepare) }
    it { should_not be_able_to(:complete, another_draft.prepare) }
    it { should     be_able_to(:restore,  fresh_correcting.prepare) }
    it { should_not be_able_to(:restore,  another_fresh_correcting.prepare) }
  end

  shared_examples_for 'correction denied' do
    it { should_not be_able_to(:accept,   fresh_correcting.review) }
    it { should_not be_able_to(:accept,   another_fresh_correcting.review) }
    it { should_not be_able_to(:refuse,   processing_correcting.review) }
    it { should_not be_able_to(:refuse,   another_processing_correcting.review) }
    it { should_not be_able_to(:complete, processing_correcting.review) }
    it { should_not be_able_to(:complete, another_processing_correcting.review) }
    it { should_not be_able_to(:restore,  fresh_publishing.review) }
    it { should_not be_able_to(:restore,  another_fresh_publishing.review) }
  end

  shared_examples_for 'correction allowed' do
    it { should     be_able_to(:accept,   fresh_correcting.review) }
    it { should     be_able_to(:accept,   another_fresh_correcting.review) }
    it { should     be_able_to(:refuse,   processing_correcting.review) }
    it { should     be_able_to(:refuse,   another_processing_correcting.review) }
    it { should     be_able_to(:complete, processing_correcting.review) }
    it { should     be_able_to(:complete, another_processing_correcting.review) }
    it { should     be_able_to(:restore,  fresh_publishing.review) }
    it { should     be_able_to(:restore,  another_fresh_publishing.review) }
  end

  shared_examples_for 'publish denied' do
    it { should_not be_able_to(:accept,   fresh_publishing.publish) }
    it { should_not be_able_to(:accept,   another_fresh_publishing.publish) }
    it { should_not be_able_to(:refuse,   processing_publishing.publish) }
    it { should_not be_able_to(:refuse,   another_processing_publishing.publish) }
    it { should_not be_able_to(:complete, processing_publishing.publish) }
    it { should_not be_able_to(:complete, another_processing_publishing.publish) }
    it { should_not be_able_to(:restore,  published.publish) }
    it { should_not be_able_to(:restore,  another_published.publish) }
  end

  shared_examples_for 'publish allowed' do
    it { should     be_able_to(:accept,   fresh_publishing.publish) }
    it { should     be_able_to(:accept,   another_fresh_publishing.publish) }
    it { should     be_able_to(:refuse,   processing_publishing.publish) }
    it { should     be_able_to(:refuse,   another_processing_publishing.publish) }
    it { should     be_able_to(:complete, processing_publishing.publish) }
    it { should     be_able_to(:complete, another_processing_publishing.publish) }
    it { should     be_able_to(:restore,  published.publish) }
    it { should     be_able_to(:restore,  another_published.publish) }
  end

  context 'tasks' do
    context 'user' do
      subject { ability_for(user) }
      it_behaves_like 'prepare denied'
      it_behaves_like 'correction denied'
      it_behaves_like 'publish denied'
    end

    context 'initiator' do
      subject         { ability_for(initiator) }
      it_behaves_like 'prepare allowed'
      it_behaves_like 'correction denied'
      it_behaves_like 'publish denied'
    end

    context 'corrector' do
      subject         { ability_for(corrector) }
      it_behaves_like 'prepare denied'
      it_behaves_like 'correction allowed'
      it_behaves_like 'publish denied'
    end

    context 'publisher' do
      subject { ability_for(publisher) }
      it_behaves_like 'prepare denied'
      it_behaves_like 'correction denied'
      it_behaves_like 'publish allowed'
    end

    context 'corrector and publisher' do
      subject { ability_for(corrector_and_publisher) }
      it_behaves_like 'prepare denied'
      it_behaves_like 'correction allowed'
      it_behaves_like 'publish allowed'
    end
  end
end
