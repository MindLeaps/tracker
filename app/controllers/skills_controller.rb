# frozen_string_literal: true

class SkillsController < HtmlController
  include Pagy::Backend
  has_scope :exclude_deleted, only: :index, type: :boolean, default: true
  has_scope :search, only: :index

  def index
    authorize Skill
    @pagy, @skills = pagy apply_scopes(policy_scope(Skill.includes(:organization)))
  end

  def create
    @skill = Skill.new skill_parameters
    authorize @skill
    if params[:add_grade]
      @skill.grade_descriptors.build
    elsif @skill.save
      return notice_and_redirect t(:skill_created, skill: @skill.skill_name), @skill
    end

    render :new
  end

  def show
    @skill = Skill.includes(:organization).find params[:id]
    @pagy, @subjects = pagy SubjectPolicy::Scope.new(current_user, @skill.subjects.includes(:assignments, :skills, :organization)).resolve
    @pagy_grades, @grade_descriptors = pagy @skill.grade_descriptors
    authorize @skill
  end

  def new
    @skill = Skill.new
    authorize @skill
  end

  def destroy
    @skill = Skill.find params.require(:id)
    authorize @skill

    if @skill.can_delete?
      @skill.deleted_at = Time.zone.now
      if @skill.save
        success title: t(:skill_deleted), text: t(:skill_deleted_text, skill_name: @skill.skill_name), link_text: t(:undo), link_path: undelete_skill_path
        redirect_to skills_path
      end
    else
      render_deletion_error
    end
  end

  def undelete
    @skill = Skill.find params.require :id
    authorize @skill
    @skill.deleted_at = nil

    notice_and_redirect t(:skill_restored, skill_name: @skill.skill_name), request.referer || skill_path(@skill) if @skill.save
  end

  private

  def skill_parameters
    params.require(:skill).permit(:skill_name, :organization_id, :skill_description, grade_descriptors_attributes: %i[mark grade_description _destroy])
  end

  def render_deletion_error
    if Grade.where(skill: @skill).count != 0
      notice_and_redirect t(:skill_not_deleted_because_grades), request.referer || skill_path(@skill)
    elsif @skill.subjects.count != 0
      notice_and_redirect t(:skill_not_deleted_because_subject), request.referer || skill_path(@skill)
    end
  end
end
