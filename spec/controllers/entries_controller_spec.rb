# encoding: utf-8

require 'spec_helper'

describe EntriesController do

  def valid_attributes
    {:body => 'Текст новости'}
  end

  describe "GET index" do
    it "assigns all entries as @entries" do
      entry = Entry.create! valid_attributes
      get :index
      assigns(:entries).should eq([entry])
    end
  end

  describe "GET show" do
    it "assigns the requested entry as @entry" do
      entry = Entry.create! valid_attributes
      get :show, :id => entry.id.to_s
      assigns(:entry).should eq(entry)
    end
  end

  describe "GET new" do
    it "assigns a new entry as @entry" do
      get :new
      assigns(:entry).should be_a_new(Entry)
    end
  end

  describe "GET edit" do
    it "assigns the requested entry as @entry" do
      entry = Entry.create! valid_attributes
      get :edit, :id => entry.id.to_s
      assigns(:entry).should eq(entry)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Entry" do
        expect {
          post :create, :entry => valid_attributes
        }.to change(Entry, :count).by(1)
      end

      it "assigns a newly created entry as @entry" do
        post :create, :entry => valid_attributes
        assigns(:entry).should be_a(Entry)
        assigns(:entry).should be_persisted
      end

      it "redirects to the created entry" do
        post :create, :entry => valid_attributes
        response.should redirect_to(Entry.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved entry as @entry" do
        # Trigger the behavior that occurs when invalid params are submitted
        Entry.any_instance.stub(:save).and_return(false)
        post :create, :entry => {}
        assigns(:entry).should be_a_new(Entry)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Entry.any_instance.stub(:save).and_return(false)
        Entry.any_instance.stub(:errors).and_return [true]
        post :create, :entry => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested entry" do
        entry = Entry.create! valid_attributes
        # Assuming there are no other entries in the database, this
        # specifies that the Entry created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Entry.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => entry.id, :entry => {'these' => 'params'}
      end

      it "assigns the requested entry as @entry" do
        entry = Entry.create! valid_attributes
        put :update, :id => entry.id, :entry => valid_attributes
        assigns(:entry).should eq(entry)
      end

      it "redirects to the entry" do
        entry = Entry.create! valid_attributes
        put :update, :id => entry.id, :entry => valid_attributes
        response.should redirect_to(entry)
      end
    end

    describe "with invalid params" do
      it "assigns the entry as @entry" do
        entry = Entry.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Entry.any_instance.stub(:save).and_return(false)
        put :update, :id => entry.id.to_s, :entry => {}
        assigns(:entry).should eq(entry)
      end

      it "re-renders the 'edit' template" do
        entry = Entry.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Entry.any_instance.stub(:errors).and_return [true]
        Entry.any_instance.stub(:save).and_return(false)
        put :update, :id => entry.id.to_s, :entry => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested entry" do
      entry = Entry.create! valid_attributes
      expect {
        delete :destroy, :id => entry.id.to_s
      }.to change(Entry, :count).by(-1)
    end

    it "redirects to the entries list" do
      entry = Entry.create! valid_attributes
      delete :destroy, :id => entry.id.to_s
      response.should redirect_to(entries_url)
    end
  end

end
