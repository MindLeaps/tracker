# frozen_string_literal: true

require 'sql/queries'
include SQL # rubocop:disable Style/MixinUsage

module Analytics
  class GeneralController < AnalyticsController
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def index
      selected_organizations = find_resource_by_id_param @selected_organization_id, Organization
      selected_chapters = find_resource_by_id_param(@selected_chapter_id, Chapter) { |c| c.where(organization: selected_organizations) }
      selected_groups = find_resource_by_id_param(@selected_group_id, Group) { |g| g.where(chapter: selected_chapters) }
      @selected_students = find_resource_by_id_param(@selected_student_id, Student) { |s| s.where(group: selected_groups) }

      res2 = assesments_per_month
      @categories2 = res2[:categories].to_json
      @series2 = res2[:series].to_json
      @series4 = histogram_of_student_performance.to_json
      @series5 = histogram_of_student_performance_change.to_json
      @series6 = histogram_of_student_performance_change_by_gender.to_json
      @series10 = average_performance_per_group_by_lesson.to_json
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def histogram_of_student_performance
      conn = ActiveRecord::Base.connection.raw_connection
      res = if @selected_students.blank?
              []
            else
              conn.exec(student_performance_query(@selected_students)).values
            end

      [{ name: t(:frequency_perc), data: res }]
    end

    def histogram_of_student_performance_change_by_gender
      conn = ActiveRecord::Base.connection.raw_connection
      male_students = @selected_students.where(gender: 'M')
      female_students = @selected_students.where(gender: 'F')

      result = []

      result << { name: "#{t(:gender)} M", data: conn.exec(performance_change_query(male_students)).values } if male_students.length.positive?

      result << { name: "#{t(:gender)} F", data: conn.exec(performance_change_query(female_students)).values } if female_students.length.positive?

      result
    end

    def histogram_of_student_performance_change
      conn = ActiveRecord::Base.connection.raw_connection

      res = if @selected_students.blank?
              []
            else
              conn.exec(performance_change_query(@selected_students)).values
            end
      [{ name: t(:frequency_perc), data: res }]
    end

    def assesments_per_month # rubocop:disable Metrics/MethodLength
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
      groups = Array(get_groups_for_average_performance)

      conn = ActiveRecord::Base.connection.raw_connection
      groups.map do |group|
        result = conn.exec(average_mark_in_group_lessons(group)).values
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

    # rubocop:disable Naming/AccessorMethodName
    # rubocop:disable Metrics/MethodLength
    def get_groups_for_average_performance
      if selected_param_present_but_not_all?(@selected_student_id)
        Student.find(@selected_student_id).group
      elsif selected_param_present_but_not_all?(@selected_group_id)
        Group.includes(:chapter).find(@selected_group_id)
      elsif selected_param_present_but_not_all?(@selected_chapter_id)
        Group.includes(:chapter).where(chapter_id: @selected_chapter_id)
      elsif selected_param_present_but_not_all?(@selected_organization_id)
        Group.includes(:chapter).joins(:chapter).where(chapters: { organization_id: @selected_organization_id })
      else
        policy_scope(Group.includes(:chapter))
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Naming/AccessorMethodName
  end
end
