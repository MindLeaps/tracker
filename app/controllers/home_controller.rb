class HomeController < ApplicationController
  skip_before_action :authenticate_user
  def index
    return redirect_to students_url if current_user
    render layout: false
  end
end
