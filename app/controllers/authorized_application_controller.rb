class AuthorizedApplicationController < ApplicationController
  before_filter :authenticate_user!
  inherit_resources

  before_filter :check_ability, :except => :index

  protected

    def check_ability

      case action = params[:action].to_sym
      when :show
        action = :read
      when :edit
        action = :update
      when :new, :create
        action = :create
        resource = build_resource
      end

      resource ||= self.resource
      Ability.new(current_user).authorize! action, resource
    end
end
