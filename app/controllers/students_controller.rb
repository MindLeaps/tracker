# frozen_string_literal: true

class StudentsController < ApplicationController
  has_scope :exclude_deleted, type: :boolean, default: true

  def index
    authorize Student
    @students = apply_scopes policy_scope(Student.includes(:group, :profile_image))
  end

  def new
    authorize Student
    @student = Student.new
    @student.gender = 'M' # default for new students
  end

  def create
    @student = Student.new student_params
    authorize @student
    return link_notice_and_redirect t(:student_created, name: @student.proper_name), new_student_path, I18n.t(:create_another), @student if @student.save
    render :new
  end

  def show
    @student = Student.includes(:profile_image, :group).find params[:id]
    authorize @student
  end

  def edit
    @student = Student.find params[:id]
    authorize @student
    @student.student_images.build
  end

  def update
    @student = Student.includes(:organization).find params[:id]
    authorize @student
    return redirect_to @student if @student.update_attributes student_params

    render :edit
  end

  def destroy
    @student = Student.includes(:organization).find params.require :id
    authorize @student
    @student.deleted_at = Time.zone.now

    undo_notice_and_redirect t(:student_deleted, name: @student.proper_name), undelete_student_path, students_path if @student.save
  end

  def undelete
    @student = Student.find params.require :id
    authorize @student
    @student.deleted_at = nil

    notice_and_redirect t(:student_restored, name: @student.proper_name), students_path if @student.save
  end

  private

  def student_params
    params.require(:student).permit(*Student.permitted_params)
  end
end
