# encoding: utf-8

require 'spec_helper'

describe User do
  describe "инициатор должен получить список" do
    before { set_current_user initiator }

    it "новых задач" do
      initiator.fresh_tasks.where_values_hash.should == { :state => :fresh, :type => ['Subtask'], :executor_id => [initiator.id, nil]}
    end

    it "выполняемых мною задач" do
      initiator.processed_by_me_tasks.where_values_hash.should == {:state => :processing, :executor_id => initiator.id}
    end

    it "созданных мною задач" do
      initiator.initiated_by_me_tasks.to_sql.should =~ /\(state <> 'pending'\)/
      initiator.initiated_by_me_tasks.where_values_hash.should == {:initiator_id => initiator.id}
    end
  end

  describe "корректор должен получить список" do
    before { set_current_user initiator(:roles => :corrector) }

    it "новых задач" do
      initiator.fresh_tasks.where_values_hash.should == {:state => :fresh, :type => ['Subtask', 'Review'], :executor_id => [initiator.id, nil]}
    end

    it "выполняемых мною задач" do
      initiator.processed_by_me_tasks.where_values_hash.should == {:state => :processing, :executor_id => initiator.id}
    end

    it "созданных мною задач" do
      initiator.initiated_by_me_tasks.to_sql.should =~ /\(state <> 'pending'\)/
      initiator.initiated_by_me_tasks.where_values_hash.should == {:initiator_id => initiator.id}
    end
  end

  describe "публикатор должен получить список" do
    before { set_current_user initiator(:roles => :publisher) }

    it "новых задач" do
      initiator.fresh_tasks.where_values_hash.should == {:state => :fresh, :type => ['Subtask', 'Publish'], :executor_id => [initiator.id, nil]}
    end

    it "выполняемых мною задач" do
      initiator.processed_by_me_tasks.where_values_hash.should == {:state => :processing, :executor_id => initiator.id}
    end

    it "созданных мною задач" do
      initiator.initiated_by_me_tasks.to_sql.should =~ /\(state <> 'pending'\)/
      initiator.initiated_by_me_tasks.where_values_hash.should == {:initiator_id => initiator.id}
    end
  end

  describe "корректор+публикатор должен получить список" do
    before { set_current_user initiator(:roles => [:publisher, :corrector]) }

    it "новых задач" do
      initiator.fresh_tasks.where_values_hash.should == {:state => :fresh, :type => ['Subtask', 'Review', 'Publish'], :executor_id => [initiator.id, nil]}
    end

    it "выполняемых мною задач" do
      initiator.processed_by_me_tasks.where_values_hash.should == {:state => :processing, :executor_id => initiator.id}
    end

    it "созданных мною задач" do
      initiator.initiated_by_me_tasks.to_sql.should =~ /\(state <> 'pending'\)/
      initiator.initiated_by_me_tasks.where_values_hash.should == {:initiator_id => initiator.id}
    end
  end

end





# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  name                   :text
#  email                  :string(255)
#  encrypted_password     :string(128)
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  roles                  :text
#

