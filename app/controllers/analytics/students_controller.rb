module Analytics
  class StudentsController < AnalyticsController
    def index
      group_ids = Array(params[:group_ids]).reject { |v| all_selected?(v) }.map(&:to_i)

      if group_ids.empty?
        @students = []
        @selected_student_id = nil
        @disabled = true
        render :select
        return
      end

      @students = policy_scope(StudentAnalyticsSummary).where('enrolled_group_ids && ARRAY[?]::bigint[]', group_ids).order(:last_name, :first_name)
      selected_id = params[:student_id].presence
      @selected_student_id = (selected_id if selected_id && @students.exists?(id: selected_id))
      @disabled = false
      render :select
    end
  end
end
