# encoding: utf-8
require 'spec_helper'

describe Entry do
  it { Entry.count.should eql 0 }

  it { should have_fields(:title, :annotation, :body, :since, :until) }

  it { should have_and_belong_to_many :channels }

  it { should have_many :events }
end
