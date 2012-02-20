# encoding: utf-8

require 'spec_helper'

describe Manage::News::SubtasksController do

  describe "POST create" do
    before :each do
      sign_in initiator
    end
    it "assigns a newly created subtask as @subtask" do
      post :create, :issue_id => draft.prepare.id, :subtask => { :description => "kjkjk", :executor_id => another_initiator.id } rescue nil
      assigns(:subtask).should be_a(Subtask)
      assigns(:subtask).should be_persisted
    end
    it "should render subtask partial when subtask valid" do
      post :create, :issue_id => draft.prepare.id, :subtask => { :description => "ololo", :executor_id => another_initiator.id }
      response.should render_template("subtasks/_subtask")
    end
    it "render new when subtask invalid" do
      post :create, :issue_id => draft.prepare.id, :subtask => {}
      response.should render_template(:new)
    end
  end
end

