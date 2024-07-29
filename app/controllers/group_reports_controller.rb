class GroupReportsController < HtmlController
  skip_after_action :verify_policy_scoped
  layout 'print'
  def show
    @group = Group.includes(:chapter).find params[:id]
    authorize @group

  end
end
