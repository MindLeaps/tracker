class GroupReportsController < HtmlController
  skip_after_action :verify_policy_scoped
  layout 'print'
  def show
    @group = Group.includes(:chapter).find params[:id]
    authorize @group

    group_summaries = group_summaries_in_asceding_order
    @first_lesson = lesson_summary(group_summaries.first)
    @last_lesson = lesson_summary(group_summaries.last)
    @middle_lesson = lesson_summary(group_summaries.offset(group_summaries.size / 2).first)
    @lesson_summaries = group_summaries.last(30).map { |summary| lesson_summary(summary) }
    @lesson_summaries_lifetime = group_summaries.map { |summary| lesson_summary(summary) }

    @student_table_component = TableComponents::Table.new(pagy: @pagy, rows: student_row_reports, row_component: TableComponents::StudentRowReport)
  end

  def group_summaries_in_asceding_order
    GroupLessonSummary.where(group_id: @group.id).where.not(average_mark: nil).order(lesson_date: :asc)
  end

  def lesson_summary(summary)
    { lesson_date: summary.lesson_date, average_mark: summary.average_mark }
  end

  def student_row_reports
    student_group_summaries = StudentLessonSummary.where(group_id: @group.id).order(lesson_date: :asc)
    students = student_group_summaries.pluck(:student_id, :first_name, :last_name).uniq

    students.map do |student|
      summaries = student_group_summaries.where(student_id: student[0])

      {
        first_name: student[1],
        last_name: student[2],
        first_lesson: summaries.first.average_mark,
        middle_lesson: summaries.offset(summaries.size / 2).first.average_mark,
        last_lesson: summaries.last.average_mark
      }
    end
  end
end
