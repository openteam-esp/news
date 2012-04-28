# encoding: utf-8
require 'spec_helper'

describe Publish do
  subject { processing_publishing.tap{|e| e.update_attributes(:channels => [channel])}.publish }

  describe "закрытие" do
    before { subject.complete! }
    it { should be_completed }
    its(:entry) { should be_published }
  end

  describe 'отказ от выполнения' do
    before { subject.refuse! }
    it { should be_fresh }
    its(:entry) { should be_publishing }
  end

  describe "восстановление" do
    subject { published.publish }
    before { subject.restore! }
    it { should be_processing }
    its(:entry) { should be_publishing }
  end

  describe "доступные действия" do
    specify { Publish.new(:state => 'pending').human_state_events.should == [] }
    specify { Publish.new(:state => 'fresh').human_state_events.should == [:accept]}
    specify { Publish.new(:state => 'fresh', :deleted_at => Time.now).human_state_events.should == []}
    specify { Publish.new(:state => 'processing').human_state_events.should == [:complete, :refuse]}
    specify { Publish.new(:state => 'processing', :deleted_at => Time.now).human_state_events.should == []}
    specify { published.publish.human_state_events.should == [:restore] }
  end

  context 'draft' do
    subject { draft.publish }
    its(:initiator) { should == initiator }
    its(:executor)  { should == nil }
    its(:state)     { should == 'pending' }
  end
end



# == Schema Information
#
# Table name: tasks
#
#  id           :integer         not null, primary key
#  entry_id     :integer
#  initiator_id :integer
#  executor_id  :integer
#  state        :string(255)
#  type         :string(255)
#  comment      :text
#  created_at   :datetime
#  updated_at   :datetime
#  issue_id     :integer
#  description  :text
#  deleted_at   :datetime
#

