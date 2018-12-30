# frozen_string_literal: true

class StudentsController < ApplicationController
  include Pagy::Backend
  has_scope :exclude_deleted, only: :index, type: :boolean, default: true
  has_scope :exclude_empty, only: :performance, type: :boolean, default: true
  has_scope :table_order, only: :index, type: :hash

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
    # rubocop:disable Metrics/LineLength
    return link_notice_and_redirect t(:student_created, name: @student.proper_name), new_student_path, I18n.t(:create_another), details_student_path(@student) if @student.save

    # rubocop:enable Metrics/LineLength
    render :new
  end

  def details
    @student = Student.includes(:profile_image, :group).find params.require(:id)
    authorize @student
    set_back_url_flash
  end

  def performance
    @student = Student.find params.require(:id)
    authorize @student
    @student_lessons_details_by_subject = apply_scopes(StudentLessonDetail).where(student_id: params[:id]).order(:date).all.group_by(&:subject_id)
    redirect_to action: :details if @student_lessons_details_by_subject.empty?
    @subjects = Subject.includes(:skills, :organization).where(id: @student_lessons_details_by_subject.keys)
    set_back_url_flash
  end

  def edit
    @student = Student.find params[:id]
    authorize @student
    @student.student_images.build
  end

  def update
    @student = Student.find params[:id]
    authorize @student
    return redirect_to details_student_path(@student) if @student.update student_params

    render :edit
  end

  def destroy
    @student = Student.find params.require :id
    authorize @student
    @student.deleted_at = Time.zone.now

    undo_notice_and_redirect t(:student_deleted, name: @student.proper_name), undelete_student_path, students_path if @student.save
  end

  def undelete
    @student = Student.find params.require :id
    authorize @student
    @student.deleted_at = nil

    notice_and_redirect t(:student_restored, name: @student.proper_name), request.referer || student_path(@student) if @student.save
  end

  private

  def student_params
    params.require(:student).permit(*Student.permitted_params)
  end

  def set_back_url_flash
    flash[:back_from_student] = flash[:back_from_student] || request.referer
  end
end
