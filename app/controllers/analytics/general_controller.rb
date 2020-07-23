# frozen_string_literal: true

require 'sql/queries'
include SQL # rubocop:disable Style/MixinUsage

module Analytics
  class GeneralController < AnalyticsController # rubocop:disable Metrics/ClassLength
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    def index
      @organizations = policy_scope Organization
      @chapters = if !@selected_organization_id.nil? && (@selected_organization_id != '') && (@selected_organization_id != 'All')
                    Chapter.where(organization_id: @selected_organization_id)
                  else
                    policy_scope Chapter
                  end

      @groups = if !@selected_chapter_id.nil? && (@selected_chapter_id != '') && (@selected_chapter_id != 'All')
                  Group.where(chapter_id: @selected_chapter_id)
                elsif !@selected_organization_id.nil? && (@selected_organization_id != '') && (@selected_organization_id != 'All')
                  Group.includes(:chapter).where(chapters: { organization_id: @selected_organization_id })
                else
                  policy_scope Group
                end

      @students = if !@selected_group_id.nil? && (@selected_group_id != '') && (@selected_group_id != 'All')
                    Student.where(group_id: @selected_group_id).order(:last_name, :first_name).all
                  elsif !@selected_chapter_id.nil? && (@selected_chapter_id != '') && (@selected_chapter_id != 'All')
                    Student.includes(:group).where(groups: { chapter_id: @selected_chapter_id }).order(:last_name, :first_name).all
                  elsif !@selected_organization_id.nil? && (@selected_organization_id != '') && (@selected_organization_id != 'All')
                    Student.includes(group: :chapter).where(chapters: { organization_id: @selected_organization_id }).order(:last_name, :first_name).all
                  else
                    policy_scope Student.order(:last_name, :first_name)
                  end

      res2 = assesments_per_month
      @categories2 = res2[:categories].to_json
      @series2 = res2[:series].to_json
      @series4 = histogram_of_student_performance.to_json
      @series5 = histogram_of_student_performance_change.to_json
      @series6 = histogram_of_student_performance_change_by_gender.to_json
      @series10 = average_performance_per_group_by_lesson.to_json
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
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
        { name: "#{t(:group)} #{group.group_chapter_name}", data: result }
      end
    end

    # rubocop:disable Naming/AccessorMethodName
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    def get_groups_for_average_performance # rubocop:disable Metrics/CyclomaticComplexity
      if @selected_student_id.present? && @selected_student_id != 'All'
        Student.find(@selected_student_id).group
      elsif @selected_group_id.present? && @selected_group_id != 'All'
        Group.includes(:chapter).find(@selected_group_id)
      elsif @selected_chapter_id.present? && @selected_chapter_id != 'All'
        Group.includes(:chapter).where(chapter_id: @selected_chapter_id)
      elsif @selected_organization_id.present? && @selected_organization_id != 'All'
        Group.includes(:chapter).joins(:chapter).where(chapters: { organization_id: @selected_organization_id })
      else
        @groups.includes(:chapter)
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Naming/AccessorMethodName
  end
end
