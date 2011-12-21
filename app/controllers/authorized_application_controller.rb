class AuthorizedApplicationController < ApplicationController
  before_filter :authenticate_user!
  inherit_resources

  before_filter :check_ability, :except => :index

  protected

    def check_ability
      User.current = current_user
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
