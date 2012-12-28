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

describe Subtask do

  context 'родительская задача' do
    subject { processing_correcting.review.subtasks.create!({:description => "подзадача", :executor => another_corrector, :current_user => corrector}, :without_protection => true) }
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

  def subtask(state)
    Subtask.new({:state => state}, :without_protection => true)
  end

  describe "#human_state_events" do
    specify { subtask('fresh').human_state_events.should == [:accept, :refuse, :cancel] }
    specify { subtask('processing').human_state_events.should == [:complete, :refuse, :cancel] }
    specify { subtask('completed').human_state_events.should == [] }
    specify { subtask('refused').human_state_events.should == [] }
    specify { subtask('canceled').human_state_events.should == [] }
  end
end
