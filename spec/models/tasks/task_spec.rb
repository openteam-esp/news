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

  describe '.folder' do

    def where_value(key)
      subject.where_values_hash.should include(key)
      subject.where_values_hash[key]
    end

    shared_examples_for 'folder' do
      describe '#to_sql' do
        subject { folder.to_sql }
        it { should =~ /"entries"."deleted_at" IS NULL/ }
        it { should include "\"entries\".\"state\" IN ('draft', 'correcting', 'publishing')" }
        it { should include "\"channels\".\"id\" IN (#{Channel.subtree_for(current_user).select(:id).to_sql})" }
      end
    end

    subject { folder }

    context 'fresh' do
      let(:folder) { Task.folder(:fresh, current_user) }
      shared_examples_for 'fresh' do
        it_behaves_like 'folder'

        its(:to_sql) { should =~ /"tasks"."executor_id" IS NULL OR "tasks"."executor_id" = #{current_user.id}/ }

        specify { where_value(:state).should == :fresh  }
        specify { where_value(:type).should include('Subtask') }
      end

      context 'для инициатора' do
        let(:current_user) { initiator_of(channel) }
        it_behaves_like 'fresh'
      end

      context 'для корректора' do
        let(:current_user) { corrector_of(channel) }
        it_behaves_like 'fresh'
        specify { where_value(:type).should include('Review') }
      end

      context 'для публикатора' do
        let(:current_user) { publisher_of(channel) }
        it_behaves_like 'fresh'
        specify { where_value(:type).should include('Publish') }
      end

      context 'для менеджера' do
        let(:current_user) { manager_of(channel) }
        it_behaves_like 'fresh'
        specify { where_value(:type).should include('Review', 'Publish') }
      end
    end

    context 'initiated_by_me' do
      let(:folder) { Task.folder(:initiated_by_me, current_user) }

      shared_examples_for 'initiated_by_me' do
        it_behaves_like 'folder'

        specify { where_value(:initiator_id).should == current_user.id }
        its(:to_sql) { should include "\"tasks\".\"state\" IN ('fresh', 'processing', 'refused', 'canceled', 'processing', 'fresh', 'processing', 'fresh', 'processing')" }

      end

      context 'для инициатора' do
        let(:current_user) { initiator_of(channel) }
        it_behaves_like 'initiated_by_me'
      end

      context 'для корректора' do
        let(:current_user) { corrector_of(channel) }
        it_behaves_like 'initiated_by_me'
      end

      context 'для публикатора' do
        let(:current_user) { publisher_of(channel) }
        it_behaves_like 'initiated_by_me'
      end

      context 'для корректора и публикатора' do
        let(:current_user) { manager_of(channel) }
        it_behaves_like 'initiated_by_me'
      end
    end

    context 'processed_by_me' do
      let(:folder) { Task.folder(:processed_by_me, current_user) }

      shared_examples_for 'processed_by_me' do
        it_behaves_like 'folder'

        specify { where_value(:executor_id).should == current_user.id }
        specify { where_value(:state).should == :processing }
      end

      context 'для инициатора' do
        let(:current_user) { initiator_of(channel) }
        it_behaves_like 'processed_by_me'
      end

      context 'для корректора' do
        let(:current_user) { corrector_of(channel) }
        it_behaves_like 'processed_by_me'
      end

      context 'для публикатора' do
        let(:current_user) { publisher_of(channel) }
        it_behaves_like 'processed_by_me'
      end

      context 'для корректора и публикатора' do
        let(:current_user) { manager_of(channel) }
        it_behaves_like 'processed_by_me'
      end
    end
  end
end
