# frozen_string_literal: true
module Api
  class GroupsController < ApiController
    def index
      @groups = Group.all
      respond_with @groups, meta: { timestamp: Time.zone.now }
    end

    def show
      @group = Group.find params.require :id
      respond_with @group, meta: { timestamp: Time.zone.now }
    end
  end
end
