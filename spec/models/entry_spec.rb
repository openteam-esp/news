# encoding: utf-8
require 'spec_helper'

describe "Статья" do
  it "должна писаться в хранилище" do
     Entry.create.should be_persisted
  end
end
