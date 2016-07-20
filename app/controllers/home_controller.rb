class HomeController < ApplicationController
  def index
    return redirect_to students_url if current_user
    render layout: false
  end
end
