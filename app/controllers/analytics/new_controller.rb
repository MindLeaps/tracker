module Analytics
  class NewController < AnalyticsController
    def index
      @from = params[:from] || Date.new(Date.current.year - 1, 1, 1).to_s
      @to = params[:to] || Time.zone.today.to_s
      @number_of_data_points = 0
      @selected_summaries = filter_summaries
    end

    def filter_summaries
      filtered_summaries = fetch_summaries.where(lesson_date: @from..@to)
      @total_average = filtered_summaries.average(:average_mark)

      create_series(filtered_summaries)
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def create_series(summaries)
      summaries.group_by(&:group_id).map do |id, entries|
        series = []
        is_student_summary = entries[0].is_a?(StudentLessonSummary)
        series << {
          name: is_student_summary ? "#{entries[0].first_name} #{entries[0].last_name}" : entries[0].group_chapter_name,
          is_student_series: is_student_summary,
          data: entries.map.with_index do |entry, i|
            @number_of_data_points += entry.grade_count
            { x: i + 1, y: entry.average_mark, date: entry.lesson_date, lesson_url: lesson_path(entry.lesson_id), grade_count: entry.grade_count,
              attendance: if is_student_summary
                            entry.grade_count.positive? ? 100 : 0
                          else
                            entry.attendance
                          end
            }
          end
        }
        { series: series, id: }
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    private

    def fetch_summaries
      if selected_param_present_but_not_all?(@selected_student_id)
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
    end
  end
end
