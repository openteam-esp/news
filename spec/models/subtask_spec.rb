# encoding: utf-8
require 'spec_helper'

describe Subtask do

  before do
    @entry = draft
    @prepare = draft.prepare
  end

  shared_examples_for "не изменяет задачу и новость" do
    it "не изменяет задачу" do
      draft.prepare.should == @prepare
    end

    it "не изменяет новость" do
      draft == @entry
    end
  end

  describe "создание подзадачи" do
    before do
      prepare_subtask_for(another_initiator)
    end
    it_behaves_like "не изменяет задачу и новость"
  end

  describe "принятие подзадачи" do
    before { as another_initiator do prepare_subtask_for(another_initiator).accept! end }
    it_behaves_like "не изменяет задачу и новость"
  end

  describe "выполнение подзадачи" do
    before do
      as another_initiator do
        prepare_subtask_for(another_initiator).accept!
        prepare_subtask_for(another_initiator).complete!
      end
    end
    it_behaves_like "не изменяет задачу и новость"
  end

  describe "отказ от подзадачи" do
    before { as another_initiator do prepare_subtask_for(another_initiator).refuse! end }
    it_behaves_like "не изменяет задачу и новость"
  end

  describe "отмена подзадачи" do
    before { as initiator do prepare_subtask_for(another_initiator).cancel! end }
    it_behaves_like "не изменяет задачу и новость"
  end

  describe "доступные действия" do
    it { Subtask.new(:state => 'fresh').human_state_events.should == [:accept, :refuse, :cancel] }
    it { Subtask.new(:state => 'fresh', :deleted_at => Time.now).human_state_events.should == [] }
    it { Subtask.new(:state => 'processing').human_state_events.should == [:complete, :refuse, :cancel] }
    it { Subtask.new(:state => 'processing', :deleted_at => Time.now()).human_state_events.should == [] }
    it { Subtask.new(:state => 'completed').human_state_events.should == [] }
    it { Subtask.new(:state => 'refused').human_state_events.should == [] }
    it { Subtask.new(:state => 'canceled').human_state_events.should == [] }
  end
end
