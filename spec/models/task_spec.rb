# encoding: utf-8
require 'spec_helper'

describe Task do
  it { should belong_to :entry }
  it { should belong_to(:initiator) }
  it { should belong_to(:executor) }
  it { Task.scoped.to_sql.should == Task.unscoped.order('id').to_sql }

  describe "авторизованный пользователь с ролями публикатора и корректора может выполнять" do
    before { User.current = initiator(:roles => [:corrector, :publisher]) }
    describe "закрытие задачи" do
      describe "prepare" do
        before { stored_draft.prepare.complete! }
        it { stored_draft.reload.should be_state_correcting }
        it { stored_draft.review.should be_fresh }
      end

     describe "review должно" do
       before { processing_correcting.review.complete! }
       it { processing_correcting.reload.should be_state_publishing }
       it { processing_correcting.publish.should be_fresh }
     end

     describe "publish должно" do
       before { processing_publishing.publish.complete! }
       it { processing_publishing.reload.should be_state_published }
     end
    end

    describe 'отказ от выполнения' do
      describe "review" do
        before { processing_correcting.review.cancel! }
        it { processing_correcting.review.should be_fresh }
        it { processing_correcting.reload.should be_state_correcting }
      end

      describe "publish" do
        before { processing_publishing.publish.cancel! }
        it { processing_publishing.publish.should be_fresh }
        it { processing_publishing.reload.should be_state_publishing }
      end
    end

    describe "восстановление задачи" do
      describe "prepare" do
        before { fresh_correcting.prepare.restore! }
        it { fresh_correcting.reload.should be_state_draft }
        it { fresh_correcting.review.should be_pending }
      end

      describe "review" do
        before { fresh_publishing.review.restore! }
        it { fresh_publishing.reload.should be_state_correcting }
        it { fresh_publishing.publish.should be_pending }
      end

      describe "publish" do
        before { completed_publishing.publish.restore! }
        it { completed_publishing.reload.should be_state_publishing }
        it { completed_publishing.publish.should be_processing }
      end
    end
  end

end

describe Issue do
  it { should have_many(:subtasks)}
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
#

