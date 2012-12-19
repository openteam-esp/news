# encoding: utf-8

require 'spec_helper'

describe Manage::News::EntriesController do
  before :each do
    sign_in initiator_of(channel)
  end

  describe "GET index" do
    it "assigns all entries as @entries" do
      draft
      get :index, :folder => 'draft'
      assigns(:entries).should eq([draft])
    end
  end

  describe "GET show" do
    it "assigns the requested entry as @entry" do
      get :show, :id => draft.id
      assigns(:entry).should eq(draft)
    end
  end

  describe "GET edit" do
    it "assigns the requested entry as @entry and entry must be locked" do
      get :edit, :id => draft.id
      assigns(:entry).should == draft
      assigns(:entry).should be_locked
    end
  end

  describe "POST unlock" do
    it "should unlock entry" do
      draft.lock
      post :unlock, :id => draft.id
      response.should redirect_to(manage_news_entry_path(draft))
      assigns(:entry).should_not be_locked
    end
  end

  describe "POST create" do
    before { channel }

    it "assigns a newly created entry as @entry" do
      post :create, :type => :news_entry
      assigns(:entry).should be_a(Entry)
      assigns(:entry).should be_persisted
    end

    it "redirects to the editing form of created entry" do
      post :create, :type => :news_entry
      response.should redirect_to(edit_manage_news_entry_path(assigns(:entry)))
    end
  end

  describe "DELETE destroy" do
    it "fakely destroys entry" do
      delete :destroy, :id => draft.id
      assigns(:entry).should be_persisted
    end
  end

  describe "POST revivify" do
    it "restores deleted entry" do
      post :revivify, :id => deleted_draft.id
      response.should redirect_to(manage_news_entry_path(deleted_draft))
      assigns(:entry).should_not be_deleted
    end
  end
end

