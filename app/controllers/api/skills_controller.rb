# frozen_string_literal: true
module Api
  class SkillsController < ApiController
    def index
      @skills = Skill.all
      respond_with @skills, status: :ok
    end

    def show
      @skill = Skill.find params.require(:id)
      respond_with @skill, status: :ok
    end
  end
end
