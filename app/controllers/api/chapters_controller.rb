module Api
  class ChaptersController < ApiController
    has_scope :after_timestamp
    has_scope :by_organization, as: :organization_id
    has_scope :exclude_deleted, type: :boolean

    def index
      @chapters = apply_scopes(versioned_scope(Chapter, policy_versions: [2])).all
      respond_with @chapters, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @chapter = Chapter.find params[:id]
      respond_with @chapter, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
