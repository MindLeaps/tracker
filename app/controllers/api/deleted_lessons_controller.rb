module Api
  class DeletedLessonsController < ApiController
    has_scope :after_timestamp
    has_scope :by_group, as: :group_id

    def index
      @deleted_lessons = apply_scopes(versioned_scope(DeletedLesson, policy_versions: [2])).all
      respond_with @deleted_lessons, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
