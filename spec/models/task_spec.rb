# encoding: utf-8
require 'spec_helper'

describe Task do
  it { should belong_to :entry }
  it { should belong_to(:initiator) }
  it { should belong_to(:executor) }
  it { Task.scoped.to_sql.should =~ /WHERE tasks.deleted_at IS NULL ORDER BY id desc$/ }
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

