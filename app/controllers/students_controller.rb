# frozen_string_literal: true

class StudentsController < ApplicationController
  include Pagy::Backend
  has_scope :exclude_deleted, type: :boolean, default: true
  has_scope :order, type: :hash
  has_scope :order_by_group_name

  def index
    authorize Student
    @pagy, @students = pagy apply_scopes(policy_scope(Student.includes(:group, :profile_image)))
  end

  def new
    authorize Student
    @student = Student.new
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
    @student_lessons_details_by_subject = StudentLessonDetail.where(student_id: params[:id]).order(:date).all.group_by(&:subject_id)
    @subjects = Subject.includes(:skills, :organization).where(id: @student_lessons_details_by_subject.keys)
  end

  def edit
    @student = Student.find params[:id]
    authorize @student
    @student.student_images.build
  end

  def update
    @student = Student.includes(:organization).find params[:id]
    authorize @student
    return redirect_to @student if @student.update student_params

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
