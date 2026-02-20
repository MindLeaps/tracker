module Analytics
  class SubjectController < AnalyticsController
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    def index
      @subject_series = if @selected_student_id.present? && @selected_student_id != t(:all)
                          performance_per_skill_single_student
                        else
                          performance_per_skill
                        end
    end

    private

    def performance_per_skill_single_student
      conn = ActiveRecord::Base.connection.raw_connection
      students = {}

      sql = Sql.performance_per_skill_in_lessons_per_student_query_with_dates([@selected_student_id.to_i])
      query_result = conn.exec_params(sql, [@from, @to]).values
      result = query_result.reduce({}) do |acc, e|
        student_id = e[-1]
        student_name = students[student_id] ||= Student.find(student_id).proper_name
        skill_name = e[-2]
        acc.tap do |a|
          if a.key?(skill_name)
            if a[skill_name].key?(student_name)
              a[skill_name][student_name].push(x: e[0] + 1, y: e[1], lesson_url: lesson_path(e[2]), date: e[3])
            else
              a[skill_name][student_name] = [{ x: e[0] + 1, y: e[1], lesson_url: lesson_path(e[2]), date: e[3] }]
            end
          else
            a[skill_name] = { student_name => [{ x: e[0] + 1, y: e[1], lesson_url: lesson_path(e[2]), date: e[3] }] }
          end
        end
      end
      render_performance_per_skill(result)
    end

    def performance_per_skill
      groups = policy_scope(
        if @selected_group_ids.present? && @selected_group_ids != t(:all)
          Group.where(id: @selected_group_ids)
        elsif @selected_chapter_id.present? && @selected_chapter_id != t(:all)
          Group.where(chapter_id: @selected_chapter_id)
        elsif @selected_organization_id.present? && @selected_organization_id != t(:all)
          Group.includes(:chapter).where(chapters: { organization_id: @selected_organization_id })
        else
          Group
        end
      )

      return [] if groups.empty?

      result = PerformancePerGroupPerSkillPerLesson.where(group: groups, date: @from..@to).reduce({}) do |acc, e|
        acc.tap do |a|
          if a.key?(e.skill_name)
            if a[e.skill_name].key?(e.group_chapter_name)
              a[e.skill_name][e.group_chapter_name].push(x: a[e.skill_name][e.group_chapter_name].length + 1, y: e.mark, lesson_url: lesson_path(e.lesson_id), date: e.date)
            else
              a[e.skill_name][e.group_chapter_name] = [{ x: 1, y: e.mark, lesson_url: lesson_path(e.lesson_id), date: e.date }]
            end
          else
            a[e.skill_name] = { e.group_chapter_name => [{ x: 1, y: e.mark, lesson_url: lesson_path(e.lesson_id), date: e.date }] }
          end
        end
      end
      render_performance_per_skill(result, t(:group))
    end

    def render_performance_per_skill(result, prefix = '')
      series = []
      result.each do |skill_name, hash|
        # regression = RegressionService.new.skill_regression skill_name, hash.values.map(&:length).max

        skill_series = []
        hash.each_with_index do |(group, array), index|
          skill_series << { name: "#{prefix} #{group}", data: array, color: get_color(index), regression: array.length > 1, regressionSettings: {
            type: 'polynomial',
            order: 4,
            color: get_color(index),
            name: "#{prefix} #{group} - Regression",
            lineWidth: 1
          } }
        end

        # skill_series << {name: t(:regression_curve), data: regression, color: '#FF0000', lineWidth: 1, marker: {enabled: false}}
        series << { skill: skill_name, series: skill_series }
      end
      series
    end

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
