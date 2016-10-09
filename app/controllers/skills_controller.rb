# frozen_string_literal: true
class SkillsController < ApplicationController
  def index
    @skills = Skill.all
  end

  def create
    @skill = Skill.new skill_parameters
    return notice_and_redirect t(:skill_created, skill: @skill.skill_name), @skill if @skill.save
    render :new
  end

  def show
    @skill = Skill.find params[:id]
  end

  def new
    @skill = Skill.new
  end

  private

  def skill_parameters
    params.require(:skill).permit(:skill_name, :organization_id, :skill_description, grade_descriptors_attributes: [:mark, :grade_description, :_destroy])
  end
end
