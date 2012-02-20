# encoding: utf-8
require 'spec_helper'

describe Subtask do

  context 'родительская задача' do
    subject { processing_correcting.review.subtasks.create!(:description => "подзадача", :executor => another_initiator) }
    alias_method :subtask, :subject
    alias_method :create_subtask, :subtask
    before { create_subtask }

    shared_examples 'отменяется' do
      context 'при закрытии родительской задачи' do
        before { processing_correcting.review.complete! }
        it { should be_canceled }
      end
      context 'при отказе от выполнения родительской задачи' do
        before { processing_correcting.review.refuse! }
        it { should be_canceled }
      end
    end

    context "подзадача новая" do
      it_behaves_like 'отменяется'
    end

    context "подзадача принятая" do
      before { subtask.accept! }
      it_behaves_like 'отменяется'
    end
  end

  describe "#human_state_events" do
    it { Subtask.new(:state => 'fresh').human_state_events.should == [:accept, :refuse, :cancel] }
    it { Subtask.new(:state => 'processing').human_state_events.should == [:complete, :refuse, :cancel] }
    it { Subtask.new(:state => 'completed').human_state_events.should == [] }
    it { Subtask.new(:state => 'refused').human_state_events.should == [] }
    it { Subtask.new(:state => 'canceled').human_state_events.should == [] }
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

