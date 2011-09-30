# encoding: utf-8
require 'spec_helper'

describe Issue do
  it { should have_many(:subtasks)}

  describe "подзадачи" do
    before do
      review_subtask_for(another_initiator)
    end

    shared_examples_for "отмена выполнения подзадачи" do
      it "при закрытии задачи" do
        as corrector do processing_correcting.review.complete! end
        review_subtask_for(another_initiator).should be_canceled
      end

      it "при отказе от выполнения задачи" do
        as corrector do processing_correcting.review.refuse! end
        review_subtask_for(another_initiator).should be_canceled
      end
    end

    describe "отменяются новые" do
      it_behaves_like "отмена выполнения подзадачи"
    end

    describe "отменяются принятые" do
      before { as another_initiator do review_subtask_for(another_initiator).accept! end }
      it_behaves_like "отмена выполнения подзадачи"
    end

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

