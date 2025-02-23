module Analytics
  class NewController < AnalyticsController
    def index
      @from = params[:from] || Date.new(Date.current.year - 1, 1, 1).to_s
      @to = params[:to] || Date.today.to_s
      @selected_summaries = fetch_summaries
    end

    def fetch_summaries
      filtered_summaries = if selected_param_present_but_not_all?(@selected_student_id)
                             StudentLessonSummary.where(student_id: @selected_student_id).order(:lesson_date)
                           elsif selected_param_present_but_not_all?(@selected_group_id)
                             GroupLessonSummary.where(group_id: @selected_group_id)
                           elsif selected_param_present_but_not_all?(@selected_chapter_id)
                             GroupLessonSummary.where(chapter_id: @selected_chapter_id)
                           elsif selected_param_present_but_not_all?(@selected_organization_id)
                             GroupLessonSummary.joins(:chapter).where(chapters: { organization_id: @selected_organization_id })
                           else
                             GroupLessonSummary.joins(:chapter).where(chapters: { organization_id: @available_organizations })
                           end

      filtered_summaries = filtered_summaries.where(lesson_date: @from..@to)

      create_series(filtered_summaries)
    end

    def create_series(summaries)
      summaries.group_by(&:group_id).map do |id, entries|
        series = []
        series << {
          name: entries[0].is_a?(StudentLessonSummary) ? "#{entries[0].first_name} #{entries[0].last_name}" : entries[0].group_chapter_name,
          data: entries.map.with_index { |entry, i| { x: i + 1, y: entry.average_mark, date: entry.lesson_date, lesson_url: lesson_path(entry.lesson_id), grade_count: entry.grade_count } }
        }
        { series: series, id: }
      end
    end
  end
end
