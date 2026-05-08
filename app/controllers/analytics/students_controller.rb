module Analytics
  class StudentsController < AnalyticsController
    def index
      set_student_select_assigns
      render :select
    end

    private

    def set_student_select_assigns
      @multiple = multiple?
      @students = students_for_selected_groups
      @disabled = @students.empty?
      @selected_student_ids = selected_available_student_ids
      @selected_student_id = @selected_student_ids.first
    end

    def students_for_selected_groups
      return StudentAnalyticsSummary.none if selected_group_ids.empty?

      policy_scope(StudentAnalyticsSummary).where('enrolled_group_ids && ARRAY[?]::bigint[]', selected_group_ids).order(:last_name, :first_name)
    end

    def selected_group_ids
      normalized_ids(params[:group_ids]).reject { |id| all_selected?(id) }.map(&:to_i)
    end

    def selected_available_student_ids
      selected_ids = normalized_ids(params[:student_ids].presence || params[:student_id])
      selected_ids.select { |id| @students.exists?(id:) }
    end

    def multiple?
      ActiveModel::Type::Boolean.new.cast(params[:multiple])
    end
  end
end
