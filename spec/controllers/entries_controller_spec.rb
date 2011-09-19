# encoding: utf-8

require 'spec_helper'

describe EntriesController do
  before :each do
    sign_in initiator
    set_current_user initiator
  end

  describe "GET index" do
    it "assigns all entries as @entries" do
      entry = create_draft_entry
      get :index, 'state' => 'draft'
      assigns(:entries).should eq([entry])
    end
  end

  describe "GET show" do
    it "assigns the requested entry as @entry" do
      get :show, :id => draft_entry.id
      assigns(:entry).should eq(draft_entry)
    end
  end

  describe "GET edit" do
    it "assigns the requested entry as @entry" do
      get :edit, :id => draft_entry.id
      assigns(:entry).should eq(draft_entry)
      assigns(:entry).should be_locked
    end
  end

  describe "POST create" do
      it "creates a new Entry" do
        expect { post :create }.to change(Entry, :count).by(1)
      end

      it "assigns a newly created entry as @entry" do
        post :create
        assigns(:entry).should be_a(Entry)
        assigns(:entry).should be_persisted
      end

      it "redirects to the editing form of created entry" do
        post :create
        response.should redirect_to([:edit, Entry.last])
      end
  end

end

