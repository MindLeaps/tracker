class GroupReportsController < HtmlController
  skip_after_action :verify_policy_scoped
  layout 'print'
  def show
    @group = Group.find params[:id]
    authorize @group

    group_summaries = group_summaries_in_asceding_order
    @first_lesson = lesson_summary(group_summaries.first)
    @last_lesson = lesson_summary(group_summaries.last)
    @middle_lesson = lesson_summary(group_summaries.offset(group_summaries.size / 2).first)
    @lesson_summaries = group_summaries.last(30).map { |summary| lesson_summary(summary) }
    @lesson_summaries_lifetime = group_summaries.map { |summary| lesson_summary(summary) }
    @lesson_attendances = calculate_student_attendances
    @student_table_component = TableComponents::Table.new(pagy: @pagy, rows: student_row_reports, row_component: TableComponents::StudentRowReport)
  end

  # rubocop:disable Metrics/MethodLength
  def calculate_student_attendances
    attendances = []
    summaries = student_group_summaries_in_ascending_order
    last_lesson_date = summaries.first.lesson_date
    total = 0
    graded = 0

    summaries.each do |summary|
      if last_lesson_date != summary.lesson_date || summary == summaries.last
        attendances.push({ lesson_date: last_lesson_date, attendance: graded.to_f / total * 100 })
        last_lesson_date = summary.lesson_date
        total = 0
        graded = 0
      end
      graded += 1 if summary.average_mark?
      total += 1
    end
    attendances
  end
  # rubocop:enable Metrics/MethodLength

  def group_summaries_in_asceding_order
    GroupLessonSummary.where(group_id: @group.id).where.not(average_mark: nil).order(lesson_date: :asc)
  end

  def student_group_summaries_in_ascending_order
    StudentLessonSummary.where(group_id: @group.id).order(lesson_date: :asc)
  end

  def lesson_summary(summary)
    { lesson_date: summary.lesson_date, average_mark: summary.average_mark }
  end

  def student_row_reports
    summaries = student_group_summaries_in_ascending_order
    students = summaries.pluck(:student_id, :first_name, :last_name).uniq

    students.map do |student|
      summaries_for_student = summaries.where(student_id: student[0])

      {
        first_name: student[1],
        last_name: student[2],
        first_lesson: summaries_for_student.first.average_mark,
        middle_lesson: summaries_for_student.offset(summaries_for_student.size / 2).first.average_mark,
        last_lesson: summaries_for_student.last.average_mark
      }
    end
  end
end
