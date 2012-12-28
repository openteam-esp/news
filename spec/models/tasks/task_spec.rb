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

describe Task do
  it { should belong_to :entry }
  it { should belong_to(:initiator) }
  it { should belong_to(:executor) }
  it { Task.scoped.to_sql.should =~ /ORDER BY id desc$/ }

  describe '::folder' do

    def where_value(key)
      subject.where_values_hash.should include(key)
      subject.where_values_hash[key]
    end

    context 'fresh' do
      subject { Task.folder(:fresh, current_user) }
      shared_examples_for 'fresh' do
        its(:to_sql) { should =~ /executor_id IS NULL OR executor_id = #{current_user.id}/ }
        specify { where_value(:state).should == :fresh  }
        specify { where_value(:type).should include('Subtask') }
        specify { where_value(:deleted_at).should == nil }
      end

      context 'для инициатора' do
        let(:current_user) { initiator }
        it_behaves_like 'fresh'
      end

      context 'для корректора' do
        let(:current_user) { corrector }
        it_behaves_like 'fresh'
        specify { where_value(:type).should include('Review') }
      end

      context 'для публикатора' do
        let(:current_user) { publisher }
        it_behaves_like 'fresh'
        specify { where_value(:type).should include('Publish') }
      end

      context 'для корректора и публикатора' do
        let(:current_user) { corrector_and_publisher }
        it_behaves_like 'fresh'
        specify { where_value(:type).should include('Review', 'Publish') }
      end
    end

    context 'initiated_by_me' do
      subject { Task.folder(:initiated_by_me, current_user) }
      shared_examples_for 'initiated_by_me' do
        its(:to_sql) { should =~ /\(state <> 'pending'\)/ }
        specify { where_value(:initiator_id).should == current_user.id }
        specify { where_value(:deleted_at).should == nil }
      end
      context 'для инициатора' do
        let(:current_user) { initiator }
        it_behaves_like 'initiated_by_me'
      end
      context 'для корректора' do
        let(:current_user) { corrector }
        it_behaves_like 'initiated_by_me'
      end
      context 'для публикатора' do
        let(:current_user) { publisher }
        it_behaves_like 'initiated_by_me'
      end
      context 'для корректора и публикатора' do
        let(:current_user) { corrector_and_publisher }
        it_behaves_like 'initiated_by_me'
      end
    end

    context 'processed_by_me' do
      subject { Task.folder(:processed_by_me, current_user) }
      shared_examples_for 'processed_by_me' do
        specify { where_value(:executor_id).should == current_user.id }
        specify { where_value(:deleted_at).should == nil }
        specify { where_value(:state).should == :processing }
      end
      context 'для инициатора' do
        let(:current_user) { initiator }
        it_behaves_like 'processed_by_me'
      end
      context 'для корректора' do
        let(:current_user) { corrector }
        it_behaves_like 'processed_by_me'
      end
      context 'для публикатора' do
        let(:current_user) { publisher }
        it_behaves_like 'processed_by_me'
      end
      context 'для корректора и публикатора' do
        let(:current_user) { corrector_and_publisher }
        it_behaves_like 'processed_by_me'
      end
    end

  end
end
