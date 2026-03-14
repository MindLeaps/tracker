class StudentReportsController < HtmlController
  include CollectionHelper

  skip_after_action :verify_policy_scoped
  layout 'print'

  def show
    @student = Student.find params[:id]
    authorize @student
  end
end
