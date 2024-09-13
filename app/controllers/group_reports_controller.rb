class GroupReportsController < HtmlController
  skip_after_action :verify_policy_scoped
  layout 'print'
  def show
    @group = Group.includes(:chapter).find params[:id]
    authorize @group

    group_summaries = group_summaries_for_group_in_ascending_order
    @first_lesson = first_summary(group_summaries)
    @last_lesson = last_summary(group_summaries)
    @middle_lesson = middle_summary(group_summaries)

    @student_summaries_for_group = student_summaries_for_group_in_ascending_order
    @lesson_summaries = group_summaries.map { |summary| { lesson_date: summary.lesson_date, average_mark: summary.average_mark } }
    @lesson_summaries_lifetime = group_summaries.map { |summary| { lesson_date: summary.lesson_date, average_mark: summary.average_mark } }

    @student_table_component = TableComponents::Table.new(pagy: @pagy, rows: student_row_reports, row_component: TableComponents::StudentRowReport)
  end

  def group_summaries_for_group_in_ascending_order
    GroupLessonSummary.where(group_id: @group.id).where.not(average_mark: nil).order(lesson_date: :asc)
  end

  def student_summaries_for_group_in_ascending_order
    StudentLessonSummary.where(group_id: @group.id).order(lesson_date: :asc)
  end

  def first_summary(summaries)
    { lesson_date: summaries.first.lesson_date, average_mark: summaries.first.average_mark }
  end

  def last_summary(summaries)
    { lesson_date: summaries.last.lesson_date, average_mark: summaries.last.average_mark }
  end

  def middle_summary(summaries)
    { lesson_date: summaries.offset(summaries.size / 2).first.lesson_date, average_mark: summaries.offset(summaries.size / 2).first.average_mark }
  end

  def first_student_summary_mark(id)
    @student_summaries_for_group.where(student_id: id).first.average_mark
  end

  def last_student_summary_mark(id)
    @student_summaries_for_group.where(student_id: id).last.average_mark
  end

  def middle_student_summary_mark(id)
    student_summaries = @student_summaries_for_group.where(student_id: id)
    student_summaries.offset(student_summaries.size / 2).first.average_mark
  end

  def student_row_reports
    @student_details = @student_summaries_for_group.pluck(:student_id, :first_name, :last_name).uniq

    @student_details.map do |student|
      {
        first_name: student[1],
        last_name: student.last,
        first_lesson: first_student_summary_mark(student.first),
        middle_lesson: middle_student_summary_mark(student.first),
        last_lesson: last_student_summary_mark(student.first)
      }
    end
  end
end
