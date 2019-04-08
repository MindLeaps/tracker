# frozen_string_literal: true

module Api
  class GroupsController < ApiController
    has_scope :after_timestamp
    has_scope :exclude_deleted, type: :boolean
    has_scope :by_chapter, as: :chapter_id

    def index
      @groups = apply_scopes(@api_version == 2 ? policy_scope(Group) : Group).all
      respond_with @groups, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @group = Group.find params.require :id
      respond_with @group, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
