require "spec_helper"

describe EntriesController do
  describe "routing" do
    it "routes to #index" do
      get("/draft/entries").should route_to("entries#index", :state => 'draft')
    end

    it "routes to #show" do
      get("/entries/1").should route_to("entries#show", :id => "1")
    end

    it "routes to #edit" do
      get("/entries/1/edit").should route_to("entries#edit", :id => "1")
    end

    it "routes to #create" do
      post("/entries").should route_to("entries#create")
    end
  end
end
