module Analytics
  class StudentsController < AnalyticsController
    def index
      group_ids = Array(params[:group_ids]).reject { |v| all_selected?(v) }.map(&:to_i)

      if group_ids.empty?
        @students = []
        @selected_student_id = nil
        @selected_student_ids = []
        @multiple = multiple?
        @disabled = true
        render :select
        return
      end

      @students = policy_scope(StudentAnalyticsSummary).where('enrolled_group_ids && ARRAY[?]::bigint[]', group_ids).order(:last_name, :first_name)
      selected_ids = Array(params[:student_ids]).presence || Array(params[:student_id])
      @selected_student_ids = selected_ids.select { |id| @students.exists?(id:) }
      @selected_student_id = @selected_student_ids.first
      @multiple = multiple?
      @disabled = false
      render :select
    end

    private

    def multiple?
      ActiveModel::Type::Boolean.new.cast(params[:multiple])
    end
  end
end
