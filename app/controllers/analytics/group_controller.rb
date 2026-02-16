module Analytics
  class GroupController < AnalyticsController
    def index
      @selected_group_ids = params[:group_ids]
      @group_series = performance_per_group_by_lesson
    end

    # rubocop:disable Metrics/MethodLength
    def performance_per_group_by_lesson
      selected_groups = if @selected_group_ids.present?
                          Group.where(id: @selected_group_ids, deleted_at: nil)
                        elsif selected_param_present_but_not_all?(@selected_chapter_id)
                          Group.where(chapter_id: @selected_chapter_id, deleted_at: nil)
                        else
                          Group.joins(:chapter).where(chapters: { organization_id: @selected_organization_id }).where(deleted_at: nil)
                        end
      groups = Array(selected_groups)
      conn = ActiveRecord::Base.connection.raw_connection

      groups.map do |group|
        sql = Sql.average_mark_for_group_lessons
        params = [
          group.id,
          @from,
          @to
        ]
        result = conn.exec_params(sql, params).values

        {
          id: group.id,
          name: "#{t(:group)} #{group.group_chapter_name}",
          data: format_point_data(result)
        }
      end
    end
    # rubocop:enable Metrics/MethodLength

    def format_point_data(data)
      data.map do |e|
        {
          # Increment 'No. of Lessons' to start from 1
          x: e[0] + 1,
          y: e[1],
          lesson_url: lesson_path(e[2]),
          date: e[3]
        }
      end
    end
  end
end
