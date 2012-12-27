module Manage::ApplicationHelper
  def available_channels
    @available_channels ||= Channel.subtree_for(current_user)
  end

  def enabled_channels
    @enabled_channels ||= Channel.subtree_for(current_user).where(:entry_type => resource.class.model_name.underscore)
  end

  def disabled_channels
    @disabled_channels ||= available_channels - enabled_channels
  end

  def disabled_channel_ids
    @disabled_channel_ids ||= disabled_channels.map(&:id)
  end
end
