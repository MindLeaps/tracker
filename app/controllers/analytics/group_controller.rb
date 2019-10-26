# frozen_string_literal: true

require 'sql/queries'
include SQL # rubocop:disable Style/MixinUsage

module Analytics
  class GroupController < AnalyticsController
    def index # rubocop:disable Metrics/MethodLength
      @subject = params[:subject_select]

      @organizations = policy_scope Organization
      @chapters = if !@selected_organization_id.nil? && (@selected_organization_id != '') && (@selected_organization_id != 'All')
                    Chapter.where(organization_id: @selected_organization_id)
                  else
                    Chapter.where(organization: @organizations)
                  end

      @selected_organization_id = @organizations.first.id unless params[:organization_select]

      # figure 8: Average performance per group by days in program
      # Rebecca requested a Trellis per Group
      series8 = performance_per_group
      @count = series8.count
      @series8 = series8.to_json
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def performance_per_group
      groups = if !@selected_chapter_id.nil? && (@selected_chapter_id != '') && (@selected_chapter_id != 'All')
                 Group.where(chapter_id: @selected_chapter_id)
               # lessons = Lesson.joins(:grades).includes(:group).group('lessons.id').where(groups: {chapter_id: @selected_chapter_id})
               else
                 # lessons = Lesson.joins(:grades, group: :chapter).group('lessons.id').where(chapters: {organization_id: @selected_organization_id})
                 Group.joins(:chapter).where(chapters: { organization_id: @selected_organization_id })
               end
      conn = ActiveRecord::Base.connection.raw_connection

      groups
        .map { |group| { group_name: group.group_chapter_name, result: conn.exec(average_mark_in_group_lessons(group)).values } }
        .reject { |group_result| group_result[:result].empty? }
        .map do |group_result|
          group_series = []
          group_series << {
            name: group_result[:group_name],
            data: group_result[:result],
            regression: group_result[:result].length > 1,
            color: get_color(0),
            regressionSettings: {
              type: 'polynomial',
              order: 4,
              color: get_color(0),
              name: "#{t(:group)} #{group_result[:group_name]} - Regression",
              lineWidth: 1
            }
          }
          { group: t(:group) + ' ' + group_result[:group_name], series: group_series }
        end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
