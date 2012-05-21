# encoding: utf-8

require 'spec_helper'

describe Ability do
  context 'менеджер' do
    context 'корневого контекста' do
      subject { ability_for(manager_of(root)) }

      context 'управление контекстами' do
        it { should     be_able_to(:manage, root) }
        it { should     be_able_to(:manage, child_1) }
        it { should     be_able_to(:manage, child_1_1) }
        it { should     be_able_to(:manage, child_2) }
      end

      context 'управление каналами' do
        it { should     be_able_to(:manage, channel(root)) }
        it { should     be_able_to(:manage, channel(child_1)) }
        it { should     be_able_to(:manage, channel(child_1_1)) }
        it { should     be_able_to(:manage, channel(child_2)) }
      end

      context 'управление правами доступа' do
        it { should     be_able_to(:manage, another_manager_of(root).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_1).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_1_1).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_2).permissions.first) }
      end
    end

    context 'вложенного контекста' do
      subject { ability_for(manager_of(child_1)) }

      context 'управление контекстами' do
        it { should_not be_able_to(:manage, root) }
        it { should     be_able_to(:manage, child_1) }
        it { should     be_able_to(:manage, child_1_1) }
        it { should_not be_able_to(:manage, child_2) }
      end

      context 'управление каналами' do
        it { should_not be_able_to(:manage, channel(root)) }
        it { should     be_able_to(:manage, channel(child_1)) }
        it { should     be_able_to(:manage, channel(child_1_1)) }
        it { should_not be_able_to(:manage, channel(child_2)) }
      end

      context 'управление правами доступа' do
        it { should_not be_able_to(:manage, another_manager_of(root).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_1).permissions.first) }
        it { should     be_able_to(:manage, another_manager_of(child_1_1).permissions.first) }
        it { should_not be_able_to(:manage, another_manager_of(child_2).permissions.first) }
      end
    end

    context 'канала' do
      subject { ability_for(manager_of(channel(child_1)))}

      context 'управление контекстами' do
        it { should_not be_able_to(:manage, root) }
        it { should_not be_able_to(:manage, child_1) }
        it { should_not be_able_to(:manage, child_1_1) }
        it { should_not be_able_to(:manage, child_2) }
      end

      context 'управление подконтекстами' do
        it { should_not be_able_to(:manage, another_channel(root)) }
        it { should_not be_able_to(:manage, another_channel(child_1)) }
        it { should_not be_able_to(:manage, another_channel(child_1_1)) }
        it { should_not be_able_to(:manage, another_channel(child_2)) }
        it { should_not be_able_to(:manage, channel(child_1)) }
      end

      context 'управление правами доступа' do
        it { should_not be_able_to(:manage, another_manager_of(root).permissions.first) }
        it { should_not be_able_to(:manage, another_manager_of(child_1).permissions.first) }
        it { should_not be_able_to(:manage, another_manager_of(child_1_1).permissions.first) }
        it { should_not be_able_to(:manage, another_manager_of(child_2).permissions.first) }
      end
    end
  end
end
