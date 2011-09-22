# encoding: utf-8

require 'spec_helper'

describe EntryHelper do
  describe "composed_title" do
    it "для пустой новости" do
      composed_title(Entry.new).should == "(без заголовка)"
    end

    it "для новости с заголовком" do
      composed_title(Entry.new(:title => "заголовок")).should == "заголовок"
    end

    it "для новости с текстом" do
      composed_title(Entry.new(:body => "текст")).should == "(без заголовка) – текст"
    end

    it "для новости с заголовком и текстом" do
      composed_title(Entry.new(:title => "заголовок", :body => "текст")).should == "заголовок – текст"
    end

    it "большой текст" do
      composed_title(Entry.new(:body => "a"*100)).should == "(без заголовка) – #{'a'*81}…"
    end

    it "большой заголовок" do
      composed_title(Entry.new(:title => "a"*100)).should == "#{'a'*79}…"
    end

    it "большой заголовок + большой текст" do
      composed_title(Entry.new(:title => "a"*100, :body => "<p>" + "a"*100 + "</p>")).should == "#{'a'*79}… – #{'a'*16}…"
    end
  end

end
