module Analytics
  class GroupController < AnalyticsController
    def index
      # figure 8: Average performance per group by days in program
      # Rebecca requested a Trellis per Group
      @group_series = performance_per_group
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def performance_per_group
      groups_lesson_summaries = if selected_param_present_but_not_all?(@selected_chapter_id)
                                  GroupLessonSummary.joins(:group).where(groups: { deleted_at: nil }).where(chapter_id: @selected_chapter_id)
                                else
                                  GroupLessonSummary.joins(:group).where(groups: { deleted_at: nil }).joins(:chapter).where(chapters: { organization_id: @selected_organization_id })
                                end

      groups_lesson_summaries
        .group_by(&:group_id)
        .map do |group_id, summaries|
          group_series = []
          group_series << {
            name: summaries[0].group_chapter_name,
            data: summaries.map.with_index { |summary, i| { x: i + 1, y: summary.average_mark, date: summary.lesson_date, lesson_url: lesson_path(summary.lesson_id), grade_count: summary.grade_count } },
            regression: summaries.length > 1,
            color: get_color(0),
            regressionSettings: {
              type: 'polynomial',
              order: 4,
              color: get_color(0),
              name: "#{t(:group)} #{summaries[0].group_chapter_name} - Regression",
              lineWidth: 1
            }
          }
          { group: "#{t(:group)} #{summaries[0].group_chapter_name}", series: group_series, group_id: }
        end
        .sort_by { |e| e[:group_id] }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
