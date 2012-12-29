# encoding: utf-8
# == Schema Information
#
# Table name: tasks
#
#  id           :integer          not null, primary key
#  entry_id     :integer
#  executor_id  :integer
#  initiator_id :integer
#  issue_id     :integer
#  state        :string(255)
#  type         :string(255)
#  comment      :text
#  description  :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'spec_helper'

describe Prepare do
  context "после создания новости" do
    subject { draft.prepare }
    its(:initiator) { should == initiator_of(channel) }
    its(:executor)  { should == initiator_of(channel) }
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

  def prepare(options)
    entry = Entry.new(options.delete(:entry), :without_protection => true)
    Prepare.new(options.merge(:entry => entry), :without_protection => true)
  end

  describe "доступные действия" do
    it { prepare(:state => 'processing').human_state_events.should == [:complete] }
    it { prepare(:state => 'processing', :entry => {:deleted_at => Time.now}).human_state_events.should == [] }
    it { fresh_correcting.prepare.human_state_events.should == [:restore] }
    it {
         fresh_correcting.move_to_trash
         fresh_correcting.prepare.human_state_events.should == []
    }
  end

end
