# encoding: utf-8

require 'spec_helper'

describe Manage::ChannelsController do
  let(:channel_1) { Fabricate :channel, :title => 'channel1' }
  let(:channel_2) { Fabricate :channel, :title => 'channel2', :parent => channel_1 }
  let(:channel_3) { Fabricate :channel, :title => 'channel3', :parent => channel_2 }

  def prepare_data
    channel_3
  end

  before :all do
    ActiveRecord::IdentityMap.enabled = false
  end

  before :each do
    prepare_data

    sign_in manager
  end

  describe 'PUT update' do
    before do
      put :update, :id => channel_2.id, :channel => {:parent_id => nil}
    end

    it { should redirect_to manage_channels_path }

    it { channel_1.reload.children.should be_empty }

    it { channel_2.reload.parent.should be_nil }
    it { channel_2.reload.weight.should == '01' }

    it { channel_3.reload.ancestors.should == [channel_2] }
    it { channel_3.reload.title_path.should == 'channel2/channel3' }
    it { channel_3.reload.weight.should == '01/00' }
  end
end

