require 'spec_helper'

describe SubtasksController do
  before :each do
    sign_in corrector
    set_current_user corrector
    User.should_receive(:first).with(:conditions => { "id" => corrector.id }).and_return corrector
    Issue.should_receive(:find).at_least(1).times.with(draft.prepare.id).and_return draft.prepare
  end

  describe "POST create" do
    it "assigns a newly created subtask as @subtask" do
      as corrector do
        post :create, :issue_id => draft.prepare.id, :subtask => { :description => "kjkjk", :executor_id => initiator.id }
      end
      assigns(:subtask).should be_a(Subtask)
      assigns(:subtask).should be_persisted
    end
    it "redirects to the show view of entry" do
      as corrector do
        post :create, :issue_id => draft.prepare.id, :subtask => { :description => "ololo", :executor_id => initiator.id }
      end
      response.should redirect_to([draft])
    end
  end
end
