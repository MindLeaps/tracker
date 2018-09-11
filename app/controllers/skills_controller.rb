# frozen_string_literal: true

class SkillsController < ApplicationController
  include Pagy::Backend
  def index
    authorize Skill
    @pagy, @skills = pagy policy_scope(Skill.includes(:organization))
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

  private

  def skill_parameters
    params.require(:skill).permit(:skill_name, :organization_id, :skill_description, grade_descriptors_attributes: %i[mark grade_description _destroy])
  end
end
