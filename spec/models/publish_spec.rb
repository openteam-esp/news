# encoding: utf-8
require 'spec_helper'

describe Task do
  before { User.current = initiator(:roles => [:corrector, :publisher]) }
  describe "закрытие" do
    before { processing_publishing.publish.complete! }
    it { processing_publishing.reload.should be_published }
  end

  describe 'отказ от выполнения' do
    before { processing_publishing.publish.cancel! }
    it { processing_publishing.publish.should be_fresh }
    it { processing_publishing.reload.should be_publishing }
  end

  describe "восстановление" do
    before { completed_publishing.publish.restore! }
    it { completed_publishing.reload.should be_publishing }
    it { completed_publishing.publish.should be_processing }
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

