class GroupReportsController < HtmlController
  include CollectionHelper
  skip_after_action :verify_policy_scoped
  layout 'print'
  def show
    @group = Group.find params[:id]
    authorize @group

    @group_lesson_summaries = group_summaries_for_group.map { |summary| lesson_summary(summary) }
    @student_lesson_summaries = StudentLessonSummary.where(group_id: @group.id).order(lesson_date: :asc)
    @student_table_component = TableComponents::Table.new(pagy: @pagy, rows: student_row_reports, row_component: TableComponents::StudentRowReport)
  end

  def group_summaries_for_group
    GroupLessonSummary.where(group_id: @group.id).where.not(average_mark: nil)
  end

  def lesson_summary(summary)
    { lesson_date: summary.lesson_date, average_mark: summary.average_mark, attendance: summary.attendance }
  end

  def student_row_reports
    students = @student_lesson_summaries.pluck(:student_id, :first_name, :last_name).uniq
    students.map do |student|
      summaries_for_student = @student_lesson_summaries.where(student_id: student[0])

      {
        first_name: student[1],
        last_name: student[2],
        first_lesson: summaries_for_student.first.average_mark,
        middle_lesson: middle_from_rel(summaries_for_student).average_mark,
        last_lesson: summaries_for_student.last.average_mark
      }
    end
  end
end
