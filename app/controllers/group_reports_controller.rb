class GroupReportsController < HtmlController
  skip_after_action :verify_policy_scoped
  layout 'print'
  def show
    @group = Group.includes(:chapter).find params[:id]
    authorize @group
    group_summaries = GroupLessonSummary.where(group_id: @group.id).where.not(average_mark: nil).order(lesson_date: :asc)
    @first_lesson = { lesson_date: group_summaries.first.lesson_date, average_mark: group_summaries.first.average_mark }
    @last_lesson = { lesson_date: group_summaries.last.lesson_date, average_mark: group_summaries.last.average_mark }
    @middle_lesson = { lesson_date: group_summaries.offset(group_summaries.size / 2).first.lesson_date, average_mark: group_summaries.offset(group_summaries.size / 2).first.average_mark }

    @student_rows = apply_scopes(StudentLessonSummary.where(group_id: @group.id))
    @student_table_component = TableComponents::Table.new(pagy: nil, rows: @student_rows, row_component: TableComponents::StudentRowReport)

    @lesson_summaries = GroupLessonSummary.where(group_id: @group.id).where.not(average_mark: nil).order(lesson_date: :asc).last(30).map do |summary|
      {
        lesson_date: summary.lesson_date,
        average_mark: summary.average_mark
      }
    end

    @lesson_summaries_lifetime = GroupLessonSummary.where(group_id: @group.id).where.not(average_mark: nil).order(lesson_date: :asc).map do |summary|
      {
        lesson_date: summary.lesson_date,
        average_mark: summary.average_mark
      }
    end
    @student_table_component = TableComponents::Table.new(pagy: @pagy, rows: @student_rows, row_component: TableComponents::StudentRowReport)
  end
end
