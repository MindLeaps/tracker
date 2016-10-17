# frozen_string_literal: true
module Api
  class GroupsController < ApiController
    has_scope :after_timestamp
    has_scope :exclude_deleted, type: :boolean

    def index
      @groups = apply_scopes(Group).all
      respond_with @groups, meta: { timestamp: Time.zone.now }
    end

    def show
      @group = Group.find params.require :id
      respond_with @group, meta: { timestamp: Time.zone.now }
    end
  end
end
