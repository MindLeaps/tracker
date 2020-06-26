# frozen_string_literal: true

class StudentTagsController < HtmlController
  include Pagy::Backend
  has_scope :table_order, only: :index, type: :hash

  def index
    authorize Tag
    @pagy, @tags = pagy apply_scopes(policy_scope(Tag.includes(:organization)))
  end

  def show
    @tag = Tag.find params.require(:id)
    authorize @tag
  end

  def new
    authorize Tag
    @student_tag = Tag.new
  end

  def create
    tag = Tag.new(params.require(:tag).permit(:tag_name, :organization_id, :shared))
    authorize tag
    return link_notice_and_redirect t(:tag_created, name: tag.tag_name), new_student_tag_path, I18n.t(:create_another), student_tag_path(tag) if tag.save

    render :new
  end
end
