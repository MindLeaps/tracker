# frozen_string_literal: true
module Api
  class GroupsController < ApiController
    def index
      @groups = Group.all
      respond_with @groups, include: :students
    end

    def show
      @group = Group.find params[:id]
      respond_with @group, include: :students
    end
  end
end
