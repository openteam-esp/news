class AuthorizedApplicationController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_current_user
  inherit_resources

  protected

    def set_current_user
      User.current = current_user
    end

end
