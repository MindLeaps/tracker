module Analytics
  class NewController < AnalyticsController
    include CollectionHelper
    def index
      @from = params[:from] || Date.new(Date.current.year - 1, 1, 1).to_s
      @to = params[:to] || Time.zone.today.to_s
      @number_of_data_points = 0
      @selected_summaries = filter_summaries
    end

    def filter_summaries
      filtered_summaries = fetch_summaries
      @total_average = average_from_array(filtered_summaries.map { |s| s['average_mark'] || 0 })

      create_series(filtered_summaries)
    end

    # rubocop:disable Metrics/AbcSize
    def create_series(summaries)
      summaries.group_by { |s| s['group_id'] }.map.with_index do |(id, entries), index|
        series = []
        is_student_summary = entries[0]['student_id'].present?
        series << {
          name: is_student_summary ? "#{entries[0]['first_name']} #{entries[0]['last_name']} - #{entries[0]['group_name']}" : entries[0]['group_chapter_name'],
          is_student_series: is_student_summary,
          color: get_color(index),
          data: entries.map.with_index do |entry, i|
            @number_of_data_points += entry['grade_count']
            { x: i + 1, y: entry['average_mark'], date: entry['lesson_date'], lesson_url: lesson_path(entry['lesson_id'].to_s), attendance: entry['attendance'] }
          end
        }
        { series: series, id: }
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    # rubocop:disable Metrics/MethodLength
    def fetch_summaries
      if selected_param_present_but_not_all?(@selected_student_id)
        average_performance_per_student_by_lesson(@selected_student_id, @from, @to)
      elsif selected_param_present_but_not_all?(@selected_group_id)
        average_performance_per_group_by_lesson([@selected_group_id], @from, @to)
      elsif selected_param_present_but_not_all?(@selected_chapter_id)
        group_ids = Group.where(chapter_id: @selected_chapter_id).pluck(:id)
        average_performance_per_group_by_lesson(group_ids, @from, @to)
      elsif selected_param_present_but_not_all?(@selected_organization_id)
        group_ids = Group.includes(:chapter).where(chapters: { organization_id: @selected_organization_id }).pluck(:id)
        average_performance_per_group_by_lesson(group_ids, @from, @to)
      else
        group_ids = Group.includes(:chapter).where(chapters: { organization_id: @available_organizations }).pluck(:id)
        average_performance_per_group_by_lesson(group_ids, @from, @to)
      end
    end
    # rubocop:enable Metrics/MethodLength

    def average_performance_per_student_by_lesson(student_id, from, to)
      conn = ActiveRecord::Base.connection.raw_connection
      conn.exec(Sql.performance_in_student_lessons(student_id, from, to)).entries
    end

    def average_performance_per_group_by_lesson(group_id, from, to)
      conn = ActiveRecord::Base.connection.raw_connection
      conn.exec(Sql.performance_in_group_lessons(group_id, from, to)).entries
    end
  end
end
