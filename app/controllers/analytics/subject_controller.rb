# frozen_string_literal: true

require 'sql/queries'
include SQL # rubocop:disable Style/MixinUsage

module Analytics
  class SubjectController < AnalyticsController
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    def index
      series3 = if @selected_student_id.present? && @selected_student_id != 'All'
                  performance_per_skill_single_student
                else
                  performance_per_skill
                end
      @count = series3.count
      @series3 = series3.to_json
    end

    private

    def performance_per_skill_single_student
      conn = ActiveRecord::Base.connection.raw_connection
      students = {}

      query_result = conn.exec(performance_per_skill_in_lessons_per_student_query([@selected_student_id])).values
      result = query_result.reduce({}) do |acc, e|
        student_id = e[-1]
        student_name = students[student_id] ||= Student.find(student_id).proper_name
        skill_name = e[-2]
        acc.tap do |a|
          if a.key?(skill_name)
            if a[skill_name].key?(student_name)
              a[skill_name][student_name].push(x: e[0], y: e[1], lesson_url: lesson_path(e[2]), date: e[3])
            else
              a[skill_name][student_name] = [{ x: e[0], y: e[1], lesson_url: lesson_path(e[2]), date: e[3] }]
            end
          else
            a[skill_name] = { student_name => [{ x: e[0], y: e[1], lesson_url: lesson_path(e[2]), date: e[3] }] }
          end
        end
      end
      render_performance_per_skill(result)
    end

    def performance_per_skill
      lessons = if @selected_student_id.present? && @selected_student_id != 'All'
                  Lesson.includes(:grades).where(grades: { student_id: @selected_student_id })
                elsif @selected_group_id.present? && @selected_group_id != 'All'
                  Lesson.where(group_id: @selected_group_id)
                elsif @selected_chapter_id.present? && @selected_chapter_id != 'All'
                  Lesson.includes(:group).where(groups: { chapter_id: @selected_chapter_id })
                elsif @selected_organization_id.present? && @selected_organization_id != 'All'
                  Lesson.includes(group: :chapter).where(chapters: { organization_id: @selected_organization_id })
                else
                  Lesson.where(group: policy_scope(Group))
                end

      return [] if lessons.empty?

      conn = ActiveRecord::Base.connection.raw_connection
      groups = {}
      query_result = conn.exec(performance_per_skill_in_lessons_query(lessons)).values
      result = query_result.reduce({}) do |acc, e|
        group_id = e[-1]
        group_name = groups[group_id] ||= Group.find(group_id).group_chapter_name
        skill_name = e[-2]
        acc.tap do |a|
          if a.key?(skill_name)
            if a[skill_name].key?(group_name)
              a[skill_name][group_name].push(x: e[0], y: e[1], lesson_url: lesson_path(e[2]), date: e[3])
            else
              a[skill_name][group_name] = [{ x: e[0], y: e[1], lesson_url: lesson_path(e[2]), date: e[3] }]
            end
          else
            a[skill_name] = { group_name => [{ x: e[0], y: e[1], lesson_url: lesson_path(e[2]), date: e[3] }] }
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
