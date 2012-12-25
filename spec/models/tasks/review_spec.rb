# encoding: utf-8
require 'spec_helper'

describe Review do
  describe "авторизованный пользователь с ролями публикатора и корректора может выполнять" do
    describe "закрытие" do
      before { processing_correcting.review.complete! }
      it { processing_correcting.should be_publishing }
      it { processing_correcting.publish.should be_fresh }
    end

    describe 'отказ от выполнения' do
      before { processing_correcting.review.refuse! }
      it { processing_correcting.review.should be_fresh }
      it { processing_correcting.should be_correcting }
    end

    describe "восстановление" do
      before { fresh_publishing.review.restore! }
      it { fresh_publishing.should be_correcting }
      it { fresh_publishing.publish.should be_pending }
    end
  end

  def review(options={})
    Review.new(options, :without_protection => true)
  end

  describe "доступные действия" do
    it { review(:state => 'pending').human_state_events.should == [] }
    it { review(:state => 'fresh').human_state_events.should == [:accept]}
    it { review(:state => 'fresh', :deleted_at => Time.now).human_state_events.should == []}
    it { review(:state => 'processing').human_state_events.should == [:complete, :refuse]}
    it { review(:state => 'processing', :deleted_at => Time.now).human_state_events.should == []}
    it { fresh_publishing.review.human_state_events.should == [:restore] }
    it {
      fresh_publishing.review.deleted_at = Time.now
      fresh_publishing.review.human_state_events.should == []
    }
  end

  context 'после создания новости' do
    subject { draft.review }
    its(:initiator) { should == initiator_of(channel) }
    its(:executor)  { should == nil }
    its(:state)     { should == 'pending' }
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

