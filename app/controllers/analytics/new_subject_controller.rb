module Analytics
  class NewSubjectController < AnalyticsController
    include CollectionHelper
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def index
      @from = params[:from] || Date.new(Date.current.year - 1, 1, 1).to_s
      @to = params[:to] || Time.zone.today.to_s
      @subject_series = selected_param_present_but_not_all?(@selected_student_id) ? performance_per_skill_single_student : performance_per_skill
      @highest_rated_skill = @subject_series.max_by { |e| e&.[](:skill_average) }&.[](:skill)
    end

    private

    def performance_per_skill_single_student
      conn = ActiveRecord::Base.connection.raw_connection
      students = {}

      query_result = conn.exec(Sql.performance_per_skill_in_lessons_per_student_query([@selected_student_id], @from, @to)).entries
      result = query_result.reduce({}) do |acc, e|
        student_id = e['student_id']
        student_name = students[student_id] ||= Student.find(student_id).proper_name
        skill_name = e['skill_name']
        acc.tap do |a|
          if a.key?(skill_name)
            if a[skill_name].key?(student_name)
              a[skill_name][student_name].push(x: e['rank'] + 1, y: e['average_mark_for_skill'], lesson_url: lesson_path(e['lesson_id']), date: e['lesson_date'])
            else
              a[skill_name][student_name] = [{ x: e['rank'] + 1, y: e['average_mark_for_skill'], lesson_url: lesson_path(e['lesson_id']), date: e['lesson_date'] }]
            end
          else
            a[skill_name] = { student_name => [{ x: e['rank'] + 1, y: e['average_mark_for_skill'], lesson_url: lesson_path(e['lesson_id']), date: e['lesson_date'] }] }
          end
        end
      end
      render_performance_per_skill(result)
    end

    def performance_per_skill
      groups = fetch_groups

      return [] if groups.empty?

      result = PerformancePerGroupPerSkillPerLesson.where(group: groups).where(date: @from..@to).reduce({}) do |acc, e|
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

      render_performance_per_skill(result)
    end

    def render_performance_per_skill(result)
      series = []
      result.each do |skill_name, hash|
        skill_series = []
        skill_series_averages = []

        hash.each_with_index do |(group, array), index|
          skill_series_averages << average_from_array(array.map { |e| e[:y] })
          skill_series << { name: group, data: array, color: get_color(index) }
        end

        skill_average = average_from_array(skill_series_averages)
        series << { skill: skill_name, series: skill_series, skill_average: skill_average }
      end
      series
    end

    def fetch_groups
      policy_scope(
        if @selected_group_id.present? && @selected_group_id != 'All'
          Group.where(id: @selected_group_id)
        elsif @selected_chapter_id.present? && @selected_chapter_id != 'All'
          Group.where(chapter_id: @selected_chapter_id)
        elsif @selected_organization_id.present? && @selected_organization_id != 'All'
          Group.includes(:chapter).where(chapters: { organization_id: @selected_organization_id })
        else
          Group
        end
      )
    end

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
