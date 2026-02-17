module Analytics
  class GeneralController < AnalyticsController
    def index
      selected_organizations = find_resource_by_id_param @selected_organization_id, Organization
      selected_chapters = find_resource_by_id_param(@selected_chapter_id, Chapter) { |c| c.where(organization: selected_organizations) }
      selected_groups = find_resource_by_id_param(@selected_group_ids, Group) { |g| g.where(chapter: selected_chapters) }
      @selected_students = find_resource_by_id_param(@selected_student_id, Student) { |s| s.joins(:enrollments).where(enrollments: { group_id: selected_groups }, deleted_at: nil) }

      @assessments_per_month = assessments_per_month
      @student_performance = histogram_of_student_performance.to_json
      @student_performance_change = histogram_of_student_performance_change.to_json
      @gender_performance_change = histogram_of_student_performance_change_by_gender.to_json
      @average_group_performance = average_performance_per_group_by_lesson.to_json
      @number_of_data_points = data_points
    end

    private

    def data_points
      Grade.joins(:lesson)
           .where(student: @selected_students.select(:id), deleted_at: nil)
           .where(lessons: { date: @from..@to }).count
    end

    def histogram_of_student_performance
      conn = ActiveRecord::Base.connection.raw_connection
      res = if @selected_students.blank?
              []
            else
              sql = Sql.student_performance_query_with_dates(@selected_students.ids)
              conn.exec_params(sql, [@from, @to]).values
            end

      [{ name: t(:frequency_perc), data: res }]
    end

    def histogram_of_student_performance_change_by_gender
      result = []

      %w[M F NB].each do |gender|
        add_performance_change_results_to_set_for_gender(gender, result)
      end

      result
    end

    def add_performance_change_results_to_set_for_gender(gender, result)
      conn = ActiveRecord::Base.connection.raw_connection
      students_by_gender = @selected_students.where(gender:)
      return unless students_by_gender.length.positive?

      sql = Sql.performance_change_query_with_dates(students_by_gender.ids)
      result << { name: "#{t(:gender)} #{gender}", data: conn.exec_params(sql, [@from, @to]).values }
    end

    def histogram_of_student_performance_change
      conn = ActiveRecord::Base.connection.raw_connection

      res = if @selected_students.blank?
              []
            else
              sql = Sql.performance_change_query_with_dates(@selected_students.ids)
              conn.exec_params(sql, [@from, @to]).values
            end

      [{ name: t(:frequency_perc), data: res }]
    end

    # rubocop:disable Metrics/MethodLength
    def assessments_per_month
      conn = ActiveRecord::Base.connection.raw_connection
      group_ids = @selected_students.map(&:enrolled_group_ids).flatten.uniq
      lesson_ids = Lesson.where(group_id: group_ids).pluck(:id)
      lesson_ids_formatted = lesson_ids.map { |str| "'#{str}'" }.join(', ')
      return { categories: [], series: [{ name: t(:nr_of_assessments), data: [] }] } if lesson_ids.blank?

      sql = <<~SQL
        select to_char(date_trunc('month', l.date), 'YYYY-MM') as month,
               count(distinct(l.id, g.student_id)) as assessments
        from lessons l
        inner join grades g on l.id = g.lesson_id
        where l.id IN (#{lesson_ids_formatted})
          and g.deleted_at IS NULL
          and ($1::date IS NULL OR l.date >= $1::date)
          and ($2::date IS NULL OR l.date <= $2::date)
        group by month
        order by month;
      SQL

      res = conn.exec_params(sql, [@from, @to]).values
      {
        categories: res.pluck(0),
        series: [{ name: t(:nr_of_assessments), data: res.pluck(1) }]
      }
    end
    # rubocop:enable Metrics/MethodLength

    def average_performance_per_group_by_lesson
      groups = Array(groups_for_average_performance)
      conn = ActiveRecord::Base.connection.raw_connection
      sql = Sql.average_mark_for_group_lessons

      groups.map do |group|
        result = conn.exec_params(sql, [group.id, @from, @to]).values
        {
          name: "#{t(:group)} #{group.group_chapter_name}",
          data: format_point_data(result)
        }
      end
    end

    def format_point_data(data)
      data.map do |e|
        {
          # Increment 'No. of Lessons' to start from 1
          x: e[0] + 1,
          y: e[1],
          lesson_url: lesson_path(e[2]),
          date: e[3]
        }
      end
    end

    def groups_for_average_performance
      if @selected_group_ids.present?
        Group.where(id: @selected_group_ids, deleted_at: nil)
      elsif selected_param_present_but_not_all?(@selected_chapter_id)
        Group.where(chapter_id: @selected_chapter_id, deleted_at: nil)
      else
        Group.joins(:chapter).where(chapters: { organization_id: @selected_organization_id }).where(deleted_at: nil)
      end
    end
  end
end
