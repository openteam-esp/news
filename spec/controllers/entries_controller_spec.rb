# encoding: utf-8

require 'spec_helper'

describe EntriesController do
  before :each do
    set_current_user initiator
    sign_in initiator
    User.should_receive(:first).with(:conditions => { "id" => initiator.id }).and_return initiator
  end

  describe "GET index" do
    it "assigns all entries as @entries" do
      scope = [draft]
      Entry.should_receive(:folder).at_least(1).times.with('draft').and_return(scope)
      scope.should_receive(:page).at_least(1).times.and_return(scope)
      scope.should_receive(:per).at_least(1).times.and_return(scope)
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
      response.should redirect_to(assigns(:entry))
      assigns(:entry).should_not be_locked
    end
  end

  describe "GET delete" do
    it "assigns the requested entry as @entry" do
      get :delete, :id => draft.id
      assigns(:entry).should == draft
      assigns(:entry).should_not be_locked
    end
  end

  describe "POST create" do
      it "assigns a newly created entry as @entry" do
        post :create
        assigns(:entry).should be_a(Entry)
        assigns(:entry).should be_persisted
      end

      it "redirects to the editing form of created entry" do
        post :create
        response.should redirect_to([:edit, assigns(:entry)])
      end
  end

  describe "DELETE destroy" do
    it "fakely destroys entry" do
      delete :destroy, :id => draft.id
      assigns(:entry).should be_persisted
    end
  end

  describe "POST recycle" do
    let(:deleted_draft) { draft.destroy }
    it "restores deleted entry" do
      post :recycle, :id => deleted_draft.id
      response.should redirect_to(assigns(:entry))
      assigns(:entry).should_not be_deleted
    end
  end
end

