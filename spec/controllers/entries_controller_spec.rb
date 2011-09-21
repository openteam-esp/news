# encoding: utf-8

require 'spec_helper'

describe EntriesController do
  before :each do
    sign_in initiator
    set_current_user initiator
    User.should_receive(:first).with(:conditions => { "id" => initiator.id }).and_return initiator
  end

  def mock_find_by_id
      scoped = []
      Entry.should_receive(:scoped).and_return(scoped)
      scoped.should_receive(:find).with(draft.id).and_return(draft)
  end

  describe "GET index" do
    it "assigns all entries as @entries" do
      scope = [draft]
      Entry.should_receive(:state).at_least(1).times.with('draft').and_return(scope)
      scope.should_receive(:page).at_least(1).times.and_return(scope)
      get :index, 'state' => 'draft'
      assigns(:entries).should eq([draft])
    end
  end

  describe "GET show" do
    it "assigns the requested entry as @entry" do
      mock_find_by_id
      get :show, :id => draft.id
      assigns(:entry).should eq(draft)
    end
  end

  describe "GET edit" do
    it "assigns the requested entry as @entry" do
      mock_find_by_id
      get :edit, :id => draft.id
      assigns(:entry).should == draft
      assigns(:entry).should be_locked
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

end

