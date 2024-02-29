module Api
  class ChaptersController < ApiController
    has_scope :after_timestamp
    has_scope :by_organization, as: :organization_id
    has_scope :exclude_deleted, type: :boolean

    def index
      @chapters = apply_scopes(@api_version == 2 ? policy_scope(Chapter) : Chapter).all
      respond_with @chapters, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @chapter = Chapter.find params[:id]
      respond_with @chapter, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
