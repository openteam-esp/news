require 'spec_helper'

describe "entries/new.html.erb" do
  before(:each) do
    assign(:entry, stub_model(Entry,
      :title => "MyString"
    ).as_new_record)
  end

  it "renders new entry form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => entries_path, :method => "post" do
      assert_select "input#entry_title", :name => "entry[title]"
    end
  end
end
