class StudentReportsController < HtmlController
  include CollectionHelper

  skip_after_action :verify_policy_scoped
  layout 'print'

  def show
    @student = Student.find(params[:id])
    authorize @student

    summaries = StudentLessonSummary.where(student_id: @student.id, deleted_at: nil)
    groups_by_id = Group.where(id: summaries.filter_map(&:group_id).uniq).index_by(&:id)
    lessons_by_id = Lesson.where(id: summaries.filter_map(&:lesson_id).uniq).index_by(&:id)

    @student_summaries = StudentLessonSummary.where(student_id: @student.id, deleted_at: nil).where.not(average_mark: nil).order(:lesson_date)
                                             .map { |s| to_lesson_summary(s, groups_by_id, lessons_by_id) }
                                             .group_by { |s| s[:group_id] }
    @performance_changes = fetch_performance_changes_by_subject(@student.id)
  end

  private

  def fetch_performance_changes_by_subject(student_id)
    sql = Sql.performance_change_summary_with_middle_by_subject_query([student_id])
    ActiveRecord::Base.connection.exec_query(sql).to_a.map(&:symbolize_keys)
  end

  def to_lesson_summary(summary, groups_by_id, lessons_by_id)
    group = groups_by_id[summary.group_id]
    lesson = lessons_by_id[summary.lesson_id]

    {
      group_name: group.group_name,
      group_id: summary.group_id,
      average_mark: summary.average_mark,
      lesson_date: summary.lesson_date,
      lesson_url: lesson ? lesson_url(lesson) : nil
    }
  end
end
