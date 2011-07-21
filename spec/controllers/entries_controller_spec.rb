# encoding: utf-8

require 'spec_helper'

describe EntriesController do
  before :each do
    @user = Fabricate(:user)
    sign_in @user

    @draft = Fabricate(:folder, :title => 'draft')
    @inbox = Fabricate(:folder, :title => 'inbox')
  end

  def valid_attributes
    {:body => 'Текст новости', :user_id => @user.id}
  end

  describe "GET index" do
    it "assigns all entries as @entries" do
      entry = @draft.entries.create! valid_attributes
      entry.send_to_corrector
      entries = @inbox.entries.all.to_a
      get :index, :folder_id => @inbox.title
      assigns(:entries).should eq(entries)
    end
  end

  describe "GET show" do
    it "assigns the requested entry as @entry" do
      entry = @draft.entries.create! valid_attributes
      get :show, :id => entry.id, :folder_id => @draft.title
      assigns(:entry).should eq(entry)
    end
  end

  describe "GET new" do
    it "assigns a new entry as @entry" do
      get :new, :folder_id => @draft.title
      assigns(:entry).should be_a_new(Entry)
    end
  end

  describe "GET edit" do
    it "assigns the requested entry as @entry" do
      entry = @draft.entries.create! valid_attributes
      get :edit, :id => entry.id, :folder_id => @draft.title
      assigns(:entry).should eq(entry)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Entry" do
        expect {
          post :create, :entry => valid_attributes, :folder_id => @draft.title
        }.to change(Entry, :count).by(1)
      end

      it "assigns a newly created entry as @entry" do
        post :create, :entry => valid_attributes, :folder_id => @draft.title
        assigns(:entry).should be_a(Entry)
        assigns(:entry).should be_persisted
      end

      it "redirects to the created entry" do
        post :create, :entry => valid_attributes, :folder_id => @draft.title
        response.should redirect_to([@draft, Entry.last])
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved entry as @entry" do
        # Trigger the behavior that occurs when invalid params are submitted
        Entry.any_instance.stub(:save).and_return(false)
        post :create, :entry => {}, :folder_id => @draft.title
        assigns(:entry).should be_a_new(Entry)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Entry.any_instance.stub(:save).and_return(false)
        Entry.any_instance.stub(:errors).and_return [true]
        post :create, :entry => {}, :folder_id => @draft.title
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested entry" do
        entry = @draft.entries.create! valid_attributes
        # Assuming there are no other entries in the database, this
        # specifies that the Entry created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Entry.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => entry.id, :entry => {'these' => 'params'}, :folder_id => @draft.title
      end

      it "assigns the requested entry as @entry" do
        entry = @draft.entries.create! valid_attributes
        put :update, :id => entry.id, :entry => valid_attributes, :folder_id => @draft.title
        assigns(:entry).should eq(entry)
      end

      it "redirects to the entry" do
        entry = @draft.entries.create! valid_attributes
        put :update, :id => entry.id, :entry => valid_attributes, :folder_id => @draft.title
        response.should redirect_to([@draft, entry])
      end
    end

    describe "with invalid params" do
      it "assigns the entry as @entry" do
        entry = @draft.entries.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Entry.any_instance.stub(:save).and_return(false)
        put :update, :id => entry.id, :entry => {}, :folder_id => @draft.title
        assigns(:entry).should eq(entry)
      end

      it "re-renders the 'edit' template" do
        entry = @draft.entries.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Entry.any_instance.stub(:errors).and_return [true]
        Entry.any_instance.stub(:save).and_return(false)
        put :update, :id => entry.id, :entry => {}, :folder_id => @draft.title
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    before do
      @trash = Fabricate(:folder, :title => 'trash')
    end

    it "destroys the requested entry" do
      entry = @draft.entries.create! valid_attributes
      entry.to_trash!

      expect {
        delete :destroy, :id => entry.id, :folder_id => @trash.title
      }.to change(Entry, :count).by(-1)
    end

    it "redirects to the entries list" do
      entry = @draft.entries.create! valid_attributes
      entry.to_trash!

      delete :destroy, :id => entry.id, :folder_id => @trash.title
      response.should redirect_to(folder_entries_path(@trash))
    end
  end

  describe 'редактирование' do
    before do
      user = Fabricate(:user, :email => 'corrector@mail.com', :roles => ['corrector', 'publisher'])
      sign_in user

      @correcting = Fabricate(:folder, :title => 'correcting')
      @published = Fabricate(:folder, :title => 'published')

      @entry = Fabricate(:entry, :folder => @draft)
      @entry.send_to_corrector
      @entry.correct!
    end

    describe 'корректор' do
      it "assigns the requested entry as @entry" do
        get :edit, :id => @entry.id, :folder_id => @correcting.title
      end

      it "updates the requested entry" do
        put :update, :id => @entry.id, :entry => valid_attributes, :folder_id => @correcting.title
      end
    end

    describe 'публикатор' do
      before do
        @entry.send_to_publisher!
        @entry.publish!
      end

      it "assigns the requested entry as @entry" do
        get :edit, :id => @entry.id, :folder_id => @published.title
      end

      it "updates the requested entry" do
        put :update, :id => @entry.id, :entry => valid_attributes, :folder_id => @published.title
      end
    end
  end
end
