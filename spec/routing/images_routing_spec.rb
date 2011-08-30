describe ImagesController do
  describe "routing" do
    before :each do
      set_current_user initiator
      @entry = draft_entry_with_asset
      @asset = @entry.assets.first
    end

    it "routes to #create" do
      get("/entries/#{@entry.id}/images/100/100/#{@asset.id}/#{@asset.file_name}").
        should route_to("images#show", :entry_id => @entry.id.to_s, :filename => @asset.file_name, :width => "100", :height => "100", :id => @asset.id.to_s)
    end
  end
end
