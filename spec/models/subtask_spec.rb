# encoding: utf-8
require 'spec_helper'

describe Subtask do
  describe "авторизованный пользователь с ролями публикатора и корректора может" do
    before { User.current = initiator(:roles => [:corrector, :publisher]) }
    describe "создавать позадачи" do
      it { stored_draft.prepare.subtasks.create! :executor => User.current }
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
#

