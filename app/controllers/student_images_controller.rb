# frozen_string_literal: true
class StudentImagesController < ApplicationController
  def index
    @student = Student.find params.require :student_id
    @new_image = StudentImage.new
  end

  def create
    @student = Student.find params.require(:student_id)
    @student.student_images.concat student_images
    @student.save
    notice_and_redirect t(:images_uploaded), student_student_images_path
  rescue ActionController::ParameterMissing => _
    image_missing
  end

  private

  def student_images
    images = params.require(:student_image).permit(filename: [])[:filename]
    images.map { |i| StudentImage.new filename: i }
  end

  def image_missing
    @new_image = StudentImage.new
    flash.alert = t :no_image_submitted
    render :index, status: :bad_request
  end
end
