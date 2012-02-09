class Manage::Channels::ChannelsController < Manage::Channels::ApplicationController
  actions :new, :create, :edit, :update, :destroy, :index
  has_scope :page, :default => 1, :only => :index
  helper_method :contexts_with_channels

  protected
    def contexts_with_channels
      @contexts_with_channels ||= current_user.
        contexts_tree.
        select{|c| c.is_a? Channel }.
        inject({}) do |hash, channel|
          hash[channel.context] ||= []
          hash[channel.context] << channel
          hash
        end
    end
end
