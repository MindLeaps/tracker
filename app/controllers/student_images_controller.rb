# frozen_string_literal: true
class StudentImagesController < ApplicationController

  def index
    @images = StudentImage.where student_id: params[:student_id]
  end

end
