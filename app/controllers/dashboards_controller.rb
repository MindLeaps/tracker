class DashboardsController < HtmlController
  skip_after_action :verify_policy_scoped
  after_action :verify_policy_scoped

  def show
    authorize :dashboard
    @chapter = policy_scope(Chapter).joins(:organization)
                                    .where(deleted_at: nil, organizations: { deleted_at: nil })
                                    .find_by(id: current_user.preferred_chapter_id)
    return unless @chapter

    @dashboard = ChapterDashboard.new(chapter: @chapter, group_id: params[:group_id], subject_id: params[:subject_id])
  end
end
