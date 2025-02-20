module Analytics
  class NewController < AnalyticsController
    def index
      @selected_group_summaries = group_summaries
    end

    def group_summaries
      filtered_summaries = if selected_param_present_but_not_all?(@selected_group_id)
                             GroupLessonSummary.where(group_id: @selected_group_id)
                           elsif selected_param_present_but_not_all?(@selected_chapter_id)
                             GroupLessonSummary.where(chapter_id: @selected_chapter_id)
                           else
                             GroupLessonSummary.joins(:chapter).where(chapters: { organization_id: @selected_organization_id })
                           end

      create_group_series(filtered_summaries)
    end

    def create_group_series(group_summaries)
      group_summaries.group_by(&:group_id).map do |group_id, summaries|
        group_series = []
        group_series << {
          name: summaries[0].group_chapter_name,
          data: summaries.map.with_index { |summary, i| { x: i + 1, y: summary.average_mark, date: summary.lesson_date, lesson_url: lesson_path(summary.lesson_id), grade_count: summary.grade_count } }
        }
        { group: "#{t(:group)} #{summaries[0].group_chapter_name}", series: group_series, group_id: }
      end
    end
  end
end
