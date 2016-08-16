class SessionsController < ApplicationController
  def create
    user = User.from_omniauth request.env['omniauth.auth']
    session[:user_id] = user.id
    redirect_to root_url
  end
end
