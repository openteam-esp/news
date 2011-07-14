# encoding: utf-8

require 'spec_helper'

describe Event do

  let :entry do Fabricate :entry end

  describe "новость создана" do
    it "создаём событие с типом send_to_corrector" do
      entry.events.create!(:type => :send_to_corrector, :text => 'опубликуйте, пжалтеста, а?')
      entry.should be_awaiting_correction
    end
  end
end
