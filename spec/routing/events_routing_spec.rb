require "spec_helper"

describe EventsController do
  describe "routing" do
    before :each do
      @entry = Fabricate :entry
    end

    it "routes to #new" do
      get("/entries/#{@entry.id}/events/new").should route_to("events#new", :entry_id => @entry.id.to_s)
    end

    it "routes to #create" do
      post("/entries/#{@entry.id}/events").should route_to("events#create", :entry_id => @entry.id.to_s)
    end
  end
end
