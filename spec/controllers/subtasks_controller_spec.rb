# encoding: utf-8

require 'spec_helper'

describe SubtasksController do

  describe "POST create" do
    before :each do
      sign_in initiator
      set_current_user initiator
      User.should_receive(:first).with(:conditions => { "id" => initiator.id }).and_return initiator
      Task.stub_chain('where.find').with(draft.prepare.id).at_least(1).times.and_return draft.prepare
      Task.should_receive(:find).with(draft.prepare.id, :conditions => nil).any_number_of_times.and_return draft.prepare
      User.should_receive(:find).with(another_initiator.id, :conditions => nil).at_most(1).times.and_return another_initiator
    end
    it "assigns a newly created subtask as @subtask" do
      as initiator do
        post :create, :issue_id => draft.prepare.id, :subtask => { :description => "kjkjk", :executor_id => another_initiator.id } rescue nil
      end
      assigns(:subtask).should be_a(Subtask)
      assigns(:subtask).should be_persisted
    end
    it "should render subtask partial when subtask valid" do
      as initiator do
        post :create, :issue_id => draft.prepare.id, :subtask => { :description => "ololo", :executor_id => another_initiator.id }
      end
      response.should render_template("subtasks/_subtask")
    end
    it "render new when subtask invalid" do
      as initiator do
        post :create, :issue_id => draft.prepare.id, :subtask => {}
      end
      response.should render_template(:new)
    end
  end
end

