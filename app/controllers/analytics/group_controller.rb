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
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def performance_per_group
      groups_lesson_summaries = if !@selected_chapter_id.nil? && (@selected_chapter_id != '') && (@selected_chapter_id != 'All')
                                  GroupLessonSummary.where(chapter_id: @selected_chapter_id)
                                else
                                  GroupLessonSummary.joins(:chapter).where(chapters: { organization_id: @selected_organization_id })
                                end

      groups_lesson_summaries
        .group_by(&:group_id)
        .map do |group_id, summaries|
          group_series = []
          group_series << {
            name: summaries[0].group_chapter_name,
            data: summaries.map.with_index { |summary, i| { x: i, y: summary.average_mark, date: summary.lesson_date, lesson_url: lesson_path(summary.lesson_id), grade_count: summary.grade_count } },
            regression: true,
            color: get_color(0),
            regressionSettings: {
              type: 'polynomial',
              order: 4,
              color: get_color(0),
              name: "#{t(:group)} #{summaries[0].group_chapter_name} - Regression",
              lineWidth: 1
            }
          }
          { group: "#{t(:group)} #{summaries[0].group_chapter_name}", series: group_series, group_id: group_id }
        end
        .sort_by { |e| e[:group_id] }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
  end
end
