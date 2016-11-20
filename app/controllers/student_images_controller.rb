# frozen_string_literal: true
class StudentImagesController < ApplicationController
  def index
    @images = StudentImage.where student_id: params.require(:student_id)
    @student = Student.find params.require :student_id
    @new_image = StudentImage.new
  end

  def create
    @student = Student.find params.require(:student_id)
    @student.student_images << StudentImage.new(params.require(:student_image).permit(:filename))
    @student.save
    notice_and_redirect t(:image_uploaded), student_student_images_path
  end
end
