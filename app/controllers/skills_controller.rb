class SkillsController < ApplicationController
  def index
    @skill = Skill.new
    @skills = Skill.all
  end

  def create
    @skill = Skill.new params.require(:skill).permit(:skill_name, :organization_id)
    return notice_and_redirect t(:skill_created, skill: @skill.skill_name), skills_url if @skill.save
    render :index
  end
end
