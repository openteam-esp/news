class Manage::Channels::ApplicationController < Manage::ApplicationController
  layout 'manage/channels/main'
  before_filter :check_permissions

  private
    def check_permissions
      authorize! :manage, :channels
    end
end
