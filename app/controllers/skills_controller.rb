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
    return notice_and_redirect t(:skill_created, skill: @skill.skill_name), @skill if @skill.save

    render :new
  end

  def show
    @skill = Skill.includes(:organization).find params[:id]
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
      undo_notice_and_redirect t(:skill_deleted, skill_name: @skill.skill_name), undelete_skill_path, skills_path if @skill.save
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
