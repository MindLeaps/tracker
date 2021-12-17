# frozen_string_literal: true

class StudentTagsController < HtmlController
  include Pagy::Backend
  has_scope :table_order, only: [:index, :show], type: :hash
  has_scope :search, only: [:index, :show]

  def index
    authorize Tag
    @pagy, @tags = pagy apply_scopes(policy_scope(StudentTagTableRow.includes(:organization), policy_scope_class: TagPolicy::Scope))
  end

  def show
    @tag = Tag.find params.require(:id)
    authorize @tag
    @student_table_component = StudentComponents::StudentTable.new { |students| pagy apply_scopes(policy_scope(students.joins("INNER JOIN student_tags ON student_id = student_table_rows.id AND tag_id = '#{@tag.id}'"))) }
  end

  def edit
    @tag = Tag.find params.require(:id)
    authorize @tag
  end

  def update
    @tag = Tag.find params.require(:id)
    authorize @tag
    return redirect_to student_tag_path(@tag) if @tag.update tag_params

    render :edit
  end

  def new
    authorize Tag
    @tag = Tag.new
  end

  def create
    tag = Tag.new tag_params
    authorize tag
    return link_notice_and_redirect t(:tag_created, name: tag.tag_name), new_student_tag_path, I18n.t(:create_another), student_tag_path(tag) if tag.save

    render :new
  end

  private

  def tag_params
    params.require(:tag).permit(:tag_name, :organization_id, :shared)
  end
end
