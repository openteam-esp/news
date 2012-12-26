module AbilitySharedExamples
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
  shared_examples_for 'can not create channels' do
    it { should_not be_able_to(:manage, channel.children.new) }
  end
end
