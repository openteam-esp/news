require 'spec_helper'

describe Issue do
  it { should belong_to :entry }
  it { should belong_to(:initiator) }
  it { should belong_to(:executor) }
  it { Issue.scoped.to_sql.should == Issue.unscoped.order('id').to_sql }


end

# == Schema Information
#
# Table name: issues
#
#  id           :integer         not null, primary key
#  entry_id     :integer
#  initiator_id :integer
#  executor_id  :integer
#  state        :string(255)
#  comment      :text
#  created_at   :datetime
#  updated_at   :datetime
#

