# encoding: utf-8
# == Schema Information
#
# Table name: tasks
#
#  id           :integer          not null, primary key
#  entry_id     :integer
#  executor_id  :integer
#  initiator_id :integer
#  issue_id     :integer
#  state        :string(255)
#  type         :string(255)
#  comment      :text
#  description  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe Publish do
  subject { processing_publishing.tap{|e| e.update_attributes({:channels => [channel]}, :without_protection => true)}.publish }

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

  def publish(options={})
    Publish.new(options, :without_protection => true)
  end

  describe "доступные действия" do
    specify { publish(:state => 'pending').human_state_events.should == [] }
    specify { publish(:state => 'fresh').human_state_events.should == [:accept]}
    specify { publish(:state => 'fresh', :deleted_at => Time.now).human_state_events.should == []}
    specify { publish(:state => 'processing').human_state_events.should == [:complete, :refuse]}
    specify { publish(:state => 'processing', :deleted_at => Time.now).human_state_events.should == []}
    specify { published.publish.human_state_events.should == [:restore] }
  end

  context 'draft' do
    subject { draft.publish }
    its(:initiator) { should == initiator_of(channel) }
    its(:executor)  { should == nil }
    its(:state)     { should == 'pending' }
  end
end
