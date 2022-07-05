# frozen_string_literal: true

class StudentsController < HtmlController
  include Pagy::Backend
  has_scope :exclude_deleted, only: :index, type: :boolean, default: true
  has_scope :exclude_empty, only: :performance, type: :boolean, default: true
  has_scope :table_order, only: [:index], type: :hash
  has_scope :table_order, only: [:show], type: :hash, default: { key: :date, order: :desc }
  has_scope :search, only: :index

  def index
    authorize Student
    @pagy, @student_rows = pagy apply_scopes(policy_scope(StudentTableRow.includes(:tags, { group: { chapter: :organization } })))
  end

  def new
    authorize Student
    @student = populate_new_student
  end

  def create
    @student = Student.new student_params
    authorize @student
    return link_notice_and_redirect t(:student_created, name: @student.proper_name), new_student_path(group_id: @student.group_id), I18n.t(:create_another), details_student_path(@student) if @student.save

    render :new
  end

  def show
    @student = Student.includes(:profile_image, group: { chapter: [:organization] }).find params.require(:id)
    authorize @student
    @student_lessons_details_by_subject = apply_scopes(StudentLessonDetail.where(student_id: params[:id])).all.group_by(&:subject_id)
    @subjects = policy_scope(Subject).includes(:skills).where(id: @student_lessons_details_by_subject.keys)
  end

  def edit
    @student = Student.find params[:id]
    authorize @student
    @student.student_images.build
  end

  def update
    @student = Student.find params[:id]
    authorize @student
    return redirect_to student_path(@student) if update_student @student

    render :edit
  end

  def destroy
    @student = Student.find params.require :id
    authorize @student
    @student.deleted_at = Time.zone.now

    undo_notice_and_redirect t(:student_deleted, name: @student.proper_name), undelete_student_path, student_path(@student) if @student.save
  end

  def undelete
    @student = Student.find params.require :id
    authorize @student
    @student.deleted_at = nil

    notice_and_redirect t(:student_restored, name: @student.proper_name), request.referer || student_path(@student) if @student.save
  end

  private

  def student_params
    p = params.require(:student)
    p[:student_tags_attributes] = p.fetch(:tag_ids, []).map { |tag_id| { tag_id: tag_id } }
    p.delete :tag_ids
    p.permit(*Student.permitted_params)
  end

  def set_back_url_flash
    flash[:back_from_student] = flash[:back_from_student] || request.referer
  end

  def populate_new_student
    student = Student.new
    student.group = Group.find(new_params[:group_id]) if new_params[:group_id]
    student
  end

  def new_params
    params.permit :group_id
  end

  def update_student(student)
    p = student_params
    tag_ids = p[:student_tags_attributes].pluck(:tag_id)
    tags = Tag.where id: tag_ids
    p.delete :student_tags_attributes
    student.tags = tags
    student.update p
  end
end
