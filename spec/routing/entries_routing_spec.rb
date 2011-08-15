require "spec_helper"

describe EntriesController do
  describe "routing" do

    it "routes to #index" do
      get("/folders/awaiting_correction/entries").should route_to("entries#index", :folder_id => 'awaiting_correction')
    end

    it "routes to #show" do
      get("/folders/awaiting_correction/entries/1").should route_to("entries#show", :id => "1", :folder_id => 'awaiting_correction')
    end

    it "routes to #edit" do
      get("/folders/correcting/entries/1/edit").should route_to("entries#edit", :id => "1", :folder_id => 'correcting')
    end

    it "routes to #create" do
      post("/folders/draft/entries").should route_to("entries#create", :folder_id => 'draft')
    end

    it "routes to #update" do
      put("/folders/correcting/entries/1").should route_to("entries#update", :id => "1", :folder_id => 'correcting')
    end
  end
end
