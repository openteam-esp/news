# encoding: utf-8
require 'spec_helper'

describe Manage::News::TasksController do

  describe "POST fire_event" do
    before(:each) do
      sign_in initiator
    end

    subject { draft.prepare }

    context "если передается комментарий" do
      before { post :fire_event, :id => subject.id, :task => { :event => 'complete', :comment => 'всё ок' } }
      its ('reload.comment') { should == 'всё ок' }
    end

    context "если нет комментария" do
      before { post :fire_event, :id => subject.id, :task => { :event => 'complete' } }
      its('reload.comment') { should be_nil }
    end
  end

end

