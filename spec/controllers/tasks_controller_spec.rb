# encoding: utf-8

require 'spec_helper'

describe TasksController do

  describe "POST fire_event" do
    before(:each) do
      sign_in initiator
      set_current_user initiator
      User.should_receive(:first).with(:conditions => { "id" => initiator.id }).and_return initiator
    end
    before do
      scoped = []
      @prepare_issue = draft.prepare
      Task.should_receive(:scoped).and_return(scoped)
      scoped.should_receive(:find).with(@prepare_issue.id).and_return(@prepare_issue)
      @prepare_issue.should_receive(:fire_events!).with(:complete)
    end

    it "если передается комментарий" do
      @prepare_issue.should_receive(:comment=).with('все ок')
      post :fire_event, :id => @prepare_issue.id, :task => { :event => 'complete', :comment => 'все ок' }
    end

    it "если нет комментария" do
      @prepare_issue.should_not_receive(:comment=)
      post :fire_event, :id => @prepare_issue.id, :task => { :event => 'complete' }
    end
  end

end

