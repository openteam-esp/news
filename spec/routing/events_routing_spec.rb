require "spec_helper"

describe EventsController do
  describe "routing" do
    before :each do
      @entry = Fabricate(:entry, :user_id => Fabricate(:user))
    end

    it "routes to #create" do
      post("/folders/awaiting_correction/entries/#{@entry.id}/events").should route_to("events#create", :entry_id => @entry.id.to_s, :folder_id => 'awaiting_correction')
    end
  end
end
