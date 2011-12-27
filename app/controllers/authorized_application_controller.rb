class AuthorizedApplicationController < ApplicationController
  before_filter :authenticate_user!
  inherit_resources

  before_filter :check_ability, :except => :index

  before_filter :set_current_user

  protected

    def set_current_user
      User.current = current_user.reload
    end

    def check_ability
      case action = params[:action].to_sym
      when :show
        action = :read
      when :new, :create
        action = :create
        resource = build_resource
      when :edit
        action = :update
      when :delete
        action = :destroy
      end

      resource ||= self.resource
      Ability.new(current_user).authorize! action, resource
    end
end
