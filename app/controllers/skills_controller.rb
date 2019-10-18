# frozen_string_literal: true

class SkillsController < ApplicationController
  include Pagy::Backend
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
    @skill.deleted_at = Time.zone.now
    undo_notice_and_redirect t(:skill_deleted, skill_name: @skill.skill_name), undelete_skill_path, skills_path if @skill.save
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
end
