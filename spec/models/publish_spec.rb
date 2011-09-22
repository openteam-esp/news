# encoding: utf-8
require 'spec_helper'

describe Task do
  before { User.current = initiator(:roles => [:corrector, :publisher]) }
  describe "закрытие" do
    before { processing_publishing.publish.complete! }
    it { processing_publishing.should be_published }
  end

  describe 'отказ от выполнения' do
    before { processing_publishing.publish.cancel! }
    it { processing_publishing.publish.should be_fresh }
    it { processing_publishing.should be_publishing }
  end

  describe "восстановление" do
    before { published.publish.restore! }
    it { published.should be_publishing }
    it { published.publish.should be_processing }
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
#

