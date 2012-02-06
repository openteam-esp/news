require "spec_helper"

describe Manage::EntriesController do
  describe "routing" do
    it "routes to #index" do
      get("/manage/draft/entries").should route_to("manage/entries#index", :folder => 'draft')
    end

    it "routes to #show" do
      get("/manage/entries/1").should route_to("manage/entries#show", :id => "1")
    end

    it "routes to #edit" do
      get("/manage/entries/1/edit").should route_to("manage/entries#edit", :id => "1")
    end

    it "routes to #create" do
      post("/manage/entries").should route_to("manage/entries#create")
    end
  end
end
