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
    save_skill_as_transaction
  rescue ActiveRecord::RecordInvalid
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
    params.require(:skill).permit(:skill_name, :organization_id, :skill_description)
  end

  def all_parameters
    params.require(:skill).permit(:skill_name, :organization_id, :skill_description, grade_descriptors_attributes: %i[mark grade_description _destroy])
  end

  def save_skill_as_transaction
    Skill.transaction do
      @skill.save!
      unless all_parameters[:grade_descriptors_attributes].nil?
        @skill.reload
        @skill.grade_descriptors = Skill.new(all_parameters).grade_descriptors
        @skill.save!
      end
      return notice_and_redirect t(:skill_created, skill: @skill.skill_name), @skill
    end
  end
end
