# encoding: utf-8
require 'spec_helper'

describe Publish do
  let(:publish) { processing_publishing(:channels => [channel]).publish }
  describe "закрытие" do
    before { as publisher do publish.complete! end }
    it { processing_publishing.should be_published }
  end

  describe 'отказ от выполнения' do
    before { as publisher do publish.refuse! end }
    it { publish.should be_fresh }
    it { processing_publishing.should be_publishing }
  end

  describe "восстановление" do
    before { as publisher do published.publish.restore! end }
    it { published.should be_publishing }
    it { published.publish.should be_processing }
  end

  describe "доступные действия" do
    it { Publish.new(:state => 'pending').human_state_events.should == [] }
    it { Publish.new(:state => 'fresh').human_state_events.should == [:accept]}
    it { Publish.new(:state => 'fresh', :deleted_at => Time.now).human_state_events.should == []}
    it { Publish.new(:state => 'processing').human_state_events.should == [:complete, :refuse]}
    it { Publish.new(:state => 'processing', :deleted_at => Time.now).human_state_events.should == []}
    it { published.publish.human_state_events.should == [:restore] }
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

