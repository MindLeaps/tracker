# frozen_string_literal: true
module Api
  class GradesController < ApiController
    def show
      @grade = Grade.find params[:id]
      respond_with @grade
    end
  end
end
