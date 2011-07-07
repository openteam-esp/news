# encoding: utf-8

require 'spec_helper'

describe EventsController do

  def valid_attributes
    Fabricate.attributes_for :event
  end

  before :each do
    @entry = Fabricate(:entry)
  end


  describe "GET new" do
    it "assigns a new event as @event" do
      get :new, :entry_id => @entry.id
      assigns(:event).should be_a_new(Event)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Event" do
        expect {
          post :create, :entry_id => @entry.id, :event => valid_attributes
        }.to change(Event, :count).by(1)
      end

      it "assigns a newly created event as @event" do
        post :create, :entry_id => @entry.id, :event => valid_attributes
        assigns(:event).should be_a(Event)
        assigns(:event).should be_persisted
      end

      it "redirects to the created event" do
        post :create, :entry_id => @entry.id, :event => valid_attributes
        response.should redirect_to(root_path)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved event as @event" do
        # Trigger the behavior that occurs when invalid params are submitted
        Event.any_instance.stub(:save).and_return(false)
        post :create, :entry_id => @entry.id, :event => {}
        assigns(:event).should be_a_new(Event)
      end

     it "разобраться с этим тестиком"
      #it "re-renders the 'new' template" do
        ## Trigger the behavior that occurs when invalid params are submitted
        #Event.any_instance.stub(:save).and_return(false)
        #post :create, :entry_id => @entry.id, :event => {}
        #response.should render_template("new")
      #end
    end
  end

end
