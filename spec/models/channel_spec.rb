# == Schema Information
#
# Table name: channels
#
#  id          :integer          not null, primary key
#  deleted_at  :datetime
#  ancestry    :string(255)
#  title       :string(255)
#  weight      :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  entry_type  :string(255)
#  title_path  :text
#  description :text
#

require File.expand_path('spec/spec_helper')

describe Channel do
  describe '#weight' do
    context 'change parent in node with children' do
      let(:channel) { Fabricate :channel }                                  # 00            => 00
      let(:channel_1) { Fabricate :channel, :parent => channel }            # 00/00         => 01
      let(:channel_1_1) { Fabricate :channel, :parent => channel_1 }        # 00/00/00      => 01/00
      let(:channel_1_1_1) { Fabricate :channel, :parent => channel_1_1 }      # 00/00/00/00   => 01/00/00

      subject { channel_1_1_1 }

      before { channel_1_1_1 }
      before { channel_1.update_attributes! :parent_id => nil }

      its(:weight) { should == '01/00/00' }
    end
  end
end
