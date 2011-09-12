# encoding: utf-8
require 'spec_helper'

describe Issue do
  it { should belong_to :entry }
  it { should belong_to(:initiator) }
  it { should belong_to(:executor) }
  it { Issue.scoped.to_sql.should == Issue.unscoped.order('id').to_sql }

  describe "закрытие задачи" do
   it "должно приводить к переходу новости в следующее состояние" do
     stored_draft.prepare.complete
     stored_draft.reload.should be_state_correcting
   end
  end


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

