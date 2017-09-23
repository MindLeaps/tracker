# frozen_string_literal: true

class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  def index
    return redirect_to students_url if current_user
    render layout: false
  end
end
