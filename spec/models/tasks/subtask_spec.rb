# encoding: utf-8
require 'spec_helper'

describe Subtask do

  context 'родительская задача' do
    subject { processing_correcting.review.subtasks.create!(:description => "подзадача", :executor => another_corrector) }
    alias_method :create_subtask, :subject
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
      before { processing_correcting.current_user = another_corrector; subject.accept!; processing_correcting.current_user = corrector }
      it_behaves_like 'отменяется'
    end
  end

  describe "#human_state_events" do
    specify { Subtask.new(:state => 'fresh').human_state_events.should == [:accept, :refuse, :cancel] }
    specify { Subtask.new(:state => 'processing').human_state_events.should == [:complete, :refuse, :cancel] }
    specify { Subtask.new(:state => 'completed').human_state_events.should == [] }
    specify { Subtask.new(:state => 'refused').human_state_events.should == [] }
    specify { Subtask.new(:state => 'canceled').human_state_events.should == [] }
  end
end

# == Schema Information
#
# Table name: tasks
#
#  comment      :text
#  created_at   :datetime         not null
#  deleted_at   :datetime
#  description  :text
#  entry_id     :integer
#  executor_id  :integer
#  id           :integer          not null, primary key
#  initiator_id :integer
#  issue_id     :integer
#  state        :string(255)
#  type         :string(255)
#  updated_at   :datetime         not null
#

