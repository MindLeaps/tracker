class ReportsController < HtmlController
  skip_after_action :verify_policy_scoped
  include Pagy::Method

  def show
    @available_organizations = policy_scope Organization.where(deleted_at: nil).order(:organization_name)
    @available_chapters = policy_scope Chapter.where(deleted_at: nil).order(:chapter_name)
    @available_groups = policy_scope Group.where(deleted_at: nil).order(:group_name)

    authorize Group, :index?
  end
end
