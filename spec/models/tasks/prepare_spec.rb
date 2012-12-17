# encoding: utf-8
require 'spec_helper'

describe Prepare do
  context "после создания новости" do
    subject { draft.prepare }
    its(:initiator) { should == initiator }
    its(:executor)  { should == initiator }
    its(:state)     { should == 'processing' }
  end

  describe "авторизованный пользователь с ролями публикатора и корректора может выполнять" do
    describe "закрытие" do
      it { fresh_correcting.should be_correcting }
      it { fresh_correcting.review.should be_fresh }
    end
    describe "восстановление" do
      before { fresh_correcting.prepare.restore! }
      it { fresh_correcting.should be_draft }
      it { fresh_correcting.review.should be_pending }
    end
  end

  describe "доступные действия" do
    it { Prepare.new(:state => 'processing').human_state_events.should == [:complete] }
    it { Prepare.new(:state => 'processing', :deleted_at => Time.now).human_state_events.should == [] }
    it { fresh_correcting.prepare.human_state_events.should == [:restore] }
    it {
      fresh_correcting.prepare.deleted_at = Time.now
      fresh_correcting.prepare.human_state_events.should == []
    }
  end

end

# == Schema Information
#
# Table name: tasks
#
#  comment      :text
#  created_at   :datetime         not null
#  deleted_at   :datetime
#  description  :text
#  entry_id     :integer
#  executor_id  :integer
#  id           :integer          not null, primary key
#  initiator_id :integer
#  issue_id     :integer
#  state        :string(255)
#  type         :string(255)
#  updated_at   :datetime         not null
#

