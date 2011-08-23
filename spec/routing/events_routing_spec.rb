require "spec_helper"

describe EventsController do
  describe "routing" do
    before :each do
      User.current = Fabricate(:user)
      @entry = Fabricate(:entry)
    end

    it "routes to #create" do
      post("/entries/#{@entry.id}/events").should route_to("events#create", :entry_id => @entry.id.to_s)
    end
  end
end
