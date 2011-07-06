# encoding: utf-8
class AuthenticationsController < ApplicationController

  protect_from_forgery :except => :create
  skip_before_filter :verify_authenticity_token, :on => :create

  def index
    @authentications = [current_user.authentication] if current_user
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.where(:provider => omniauth['provider'], :uid => omniauth['uid']).first
    if authentication
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      flash[:notice] = "Вы уже зашли как #{current_user.name} (#{current_user.provider})"
      redirect_to authentications_url
    else
      user = User.new :name => omniauth['user_info']['name'] || omniauth['user_info']['nickname'], :email => omniauth['user_info']['email']
      authentication = user.build_authentication(:provider => omniauth['provider'], :uid => omniauth['uid'])
      user.save :validate => false
      authentication.save!
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, user)
    end
  end

  def destroy
    @authentication = current_user.authentication
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end

end
