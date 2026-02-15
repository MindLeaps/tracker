module Analytics
  class StudentsController < AnalyticsController
    def index
      group_ids = Array(params[:group_ids]).reject { |v| all_selected?(v) }.map(&:to_i)

      if group_ids.empty?
        render json: []
        return
      end

      students = policy_scope(StudentAnalyticsSummary)
                 .where('enrolled_group_ids && ARRAY[?]::bigint[]', group_ids)
                 .order(:last_name, :first_name)

      render json: students.map { |s| { id: s.id, label: "#{s.last_name}, #{s.first_name}" } }
    end
  end
end
