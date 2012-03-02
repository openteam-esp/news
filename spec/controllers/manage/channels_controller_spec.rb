# encoding: utf-8

require 'spec_helper'

describe Manage::Channels::ChannelsController do
  let(:organy_vlasty) { Fabricate :context }
  let(:channel_1) { Channel.create! :title => 'channel1', :polymorphic_context => organy_vlasty.polymorphic_context_value }
  let(:channel_2) { Channel.create! :title => 'channel2', :polymorphic_context => channel_1.polymorphic_context_value }
  let(:channel_3) { Channel.create! :title => 'channel3', :polymorphic_context => channel_2.polymorphic_context_value }

  def prepare_data
    channel_3
  end

  before :all do
    ActiveRecord::IdentityMap.enabled = false
  end

  before :each do
    prepare_data

    sign_in manager_of(organy_vlasty)
  end

  describe 'PUT update' do
    before do
      put :update, :id => channel_2.id, :channel => { :polymorphic_context => organy_vlasty.polymorphic_context_value }
    end

    it { should redirect_to manage_channels_root_path }

    it { channel_1.reload.children.should be_empty }

    it { channel_2.reload.parent.should be_nil }
    it { channel_2.reload.context.should == organy_vlasty }
    it { channel_2.reload.weight.should == '01' }

    it { channel_3.reload.ancestors.should == [channel_2] }
    it { channel_3.reload.title_path.should == 'channel2/channel3' }
    it { channel_3.reload.weight.should == '01/00' }
  end
end

