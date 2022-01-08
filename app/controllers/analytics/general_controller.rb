# frozen_string_literal: true

module Analytics
  class GeneralController < AnalyticsController
    def index
      selected_organizations = find_resource_by_id_param @selected_organization_id, Organization
      selected_chapters = find_resource_by_id_param(@selected_chapter_id, Chapter) { |c| c.where(organization: selected_organizations) }
      selected_groups = find_resource_by_id_param(@selected_group_id, Group) { |g| g.where(chapter: selected_chapters) }
      @selected_students = find_resource_by_id_param(@selected_student_id, Student) { |s| s.where(group: selected_groups, deleted_at: nil) }

      @assessments_per_month = assessments_per_month
      @student_performance = histogram_of_student_performance.to_json
      @student_performance_change = histogram_of_student_performance_change.to_json
      @gender_performance_change = histogram_of_student_performance_change_by_gender.to_json
      @average_group_performance = average_performance_per_group_by_lesson.to_json
    end

    private

    def histogram_of_student_performance
      conn = ActiveRecord::Base.connection.raw_connection
      res = if @selected_students.blank?
              []
            else
              conn.exec(Sql.student_performance_query(@selected_students)).values
            end

      [{ name: t(:frequency_perc), data: res }]
    end

    def histogram_of_student_performance_change_by_gender
      conn = ActiveRecord::Base.connection.raw_connection
      male_students = @selected_students.where(gender: :male)
      female_students = @selected_students.where(gender: :female)

      result = []

      result << { name: "#{t(:gender)} M", data: conn.exec(Sql.performance_change_query(male_students)).values } if male_students.length.positive?

      result << { name: "#{t(:gender)} F", data: conn.exec(Sql.performance_change_query(female_students)).values } if female_students.length.positive?

      result
    end

    def histogram_of_student_performance_change
      conn = ActiveRecord::Base.connection.raw_connection

      res = if @selected_students.blank?
              []
            else
              conn.exec(Sql.performance_change_query(@selected_students)).values
            end
      [{ name: t(:frequency_perc), data: res }]
    end

    def assessments_per_month # rubocop:disable Metrics/MethodLength
      conn = ActiveRecord::Base.connection.raw_connection
      lesson_ids = Lesson.where(group_id: @selected_students.map(&:group_id).uniq).ids

      res = if lesson_ids.blank?
              []
            else
              conn.exec("select to_char(date_trunc('month', l.date), 'YYYY-MM') as month, count(distinct(l.id, g.student_id)) as assessments
                                            from lessons as l
                                              inner join grades as g
                                                on l.id = g.lesson_id
                                              inner join groups as gr
                                                on gr.id = l.group_id
                                            where l.id IN (#{lesson_ids.join(', ')})
                                            group by month
                                            order by month;").values
            end

      {
        categories: res.map { |e| e[0] },
        series: [{ name: t(:nr_of_assessments), data: res.map { |e| e[1] } }]
      }
    end

    def average_performance_per_group_by_lesson
      groups = Array(groups_for_average_performance)

      conn = ActiveRecord::Base.connection.raw_connection
      groups.map do |group|
        result = conn.exec(Sql.average_mark_in_group_lessons(group)).values
        {
          name: "#{t(:group)} #{group.group_chapter_name}",
          data: format_point_data(result)
        }
      end
    end

    def format_point_data(data)
      data.map do |e|
        {
          x: e[0],
          y: e[1],
          lesson_url: lesson_path(e[2]),
          date: e[3]
        }
      end
    end

    def groups_for_average_performance
      Group.where(id: @selected_students.select(:group_id))
    end
  end
end
