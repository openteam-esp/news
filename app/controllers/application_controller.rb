class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :get_layout

  protected
    def get_layout
      if devise_controller?
        'auth'
      else
        'workspace'
      end
    end
end
