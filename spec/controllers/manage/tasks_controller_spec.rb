# encoding: utf-8
require 'spec_helper'

describe Manage::News::TasksController do

  describe "PUT update" do
    before(:each) do
      sign_in initiator_of(channel)
    end

    subject { draft.prepare }

    context "если передается комментарий" do
      before { put :update, :id => subject.id, :task => { :state_event => 'complete', :comment => 'всё ок' } }
      its ('reload.comment') { should == 'всё ок' }
    end

    context "если нет комментария" do
      before { put :update, :id => subject.id, :task => { :state_event => 'complete' } }
      its('reload.comment') { should be_nil }
    end
  end

end

