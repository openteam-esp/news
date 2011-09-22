# encoding: utf-8
require 'spec_helper'

describe Subtask do

  let :subtask do draft.prepare.subtasks.create! :executor => Fabricate(:user), :description => :description end

  describe "исполнитель текущей задачи" do
    before { set_current_user(initiator) }

    it "исполнитель текущей задачи может создавать подзадачи" do
      subtask.should be_persisted
    end
  end

  #describe "инициатор подзадачи" do
    #describe "может" do
      #it "отменять fresh задачи" do
        #subtask.reject!
      #end
      #it "отменять processing задачи" do
        #processing_tasks.reject!
      #end
    #end
  #end

  #describe "исполнитель подзадчи" do
    #it "принимать подзадачи" do
      #subtask.accept!
    #end

    #it "завершать подзадачи" do
      #subtask.accept!
      #subtask.complete!
    #end

    #it "отклонять подзадачи" do
      #subtask.reject!
    #end

    #it "отвергать подзадачи" do
      #subtask.refuse!
    #end
  #end

end


# == Schema Information
#
# Table name: tasks
#
#  id           :integer         not null, primary key
#  entry_id     :integer
#  initiator_id :integer #  executor_id  :integer
#  state        :string(255)
#  type         :string(255)
#  comment      :text
#  created_at   :datetime
#  updated_at   :datetime
#  issue_id     :integer
#

