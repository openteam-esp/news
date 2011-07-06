# encoding: utf-8

require 'spec_helper'

describe Entry do

  let :entry do Fabricate :entry end

  it "после создания должно появится событие 'новость создана'" do
    entry.events.should be_one
  end

end
