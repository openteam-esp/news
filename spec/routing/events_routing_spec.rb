require "spec_helper"

describe EventsController do
  describe "routing" do
    before :each do
      @entry = Fabricate :entry
    end

    it "routes to #create" do
      post("/folders/inbox/entries/#{@entry.id}/events").should route_to("events#create", :entry_id => @entry.id.to_s, :folder_id => 'inbox')
    end
  end
end
