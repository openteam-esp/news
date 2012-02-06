class Manage::ApplicationController < ApplicationController

  esp_load_and_authorize_resource

  before_filter :set_current_user

  protected

    def set_current_user
      User.current = current_user.reload
    end

end
