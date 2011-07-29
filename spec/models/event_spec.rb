# encoding: utf-8

require 'spec_helper'

describe Event do

  let :entry do Fabricate :entry end

  describe "новость создана" do
    it "создаём событие с типом send_to_corrector" do
      entry.events.create!(:kind => :send_to_corrector, :text => 'опубликуйте, пжалтеста, а?')
      entry.reload.should be_awaiting_correction
    end
  end
end

# == Schema Information
#
# Table name: events
#
#  id         :integer         not null, primary key
#  type       :string(255)
#  text       :text
#  entry_id   :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

