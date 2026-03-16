class StudentReportsController < HtmlController
  include CollectionHelper

  skip_after_action :verify_policy_scoped
  layout 'print'

  def show
    @student = Student.find(params[:id])
    authorize @student

    @summaries = StudentLessonSummary.where(student_id: @student.id, deleted_at: nil)
    @grouped_student_summaries = group_summaries
    @performance_changes = fetch_performance_changes_by_subject(@student.id)
    @student_skill_averages = skill_average_summaries
  end

  private

  def fetch_performance_changes_by_subject(student_id)
    sql = Sql.performance_change_summary_with_middle_by_subject_query([student_id])
    ActiveRecord::Base.connection.exec_query(sql).to_a.map(&:symbolize_keys)
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/AbcSize
  def skill_average_summaries
    grouped = {}

    StudentAverage.where(student_id: @student.id).load.each do |average|
      subject_name = average[:subject_name].to_s
      grouped[subject_name] ||= []
      grouped[subject_name] << { skill: average[:skill_name], average: average[:average_mark].to_f }
    end

    grouped.transform_values do |rows|
      strongest = rows.max_by { |row| row[:average] }
      weakest = rows.min_by { |row| row[:average] }

      {
        strongest: strongest,
        weakest: weakest,
        other_skills: rows.reject do |row|
          row[:skill] == strongest[:skill] || row[:skill] == weakest[:skill]
        end
      }
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/AbcSize

  def group_summaries
    groups_by_id = Group.where(id: @summaries.filter_map(&:group_id).uniq).index_by(&:id)
    lessons_by_id = Lesson.where(id: @summaries.filter_map(&:lesson_id).uniq).index_by(&:id)

    @summaries.where.not(average_mark: nil)
              .order(:lesson_date)
              .map { |s| to_lesson_summary(s, groups_by_id, lessons_by_id) }
              .group_by { |s| s[:group_id] }
  end

  def to_lesson_summary(summary, groups_by_id, lessons_by_id)
    group = groups_by_id[summary.group_id]
    lesson = lessons_by_id[summary.lesson_id]

    {
      group_name: group&.group_name || "Group #{summary.group_id}",
      group_id: summary.group_id,
      average_mark: summary.average_mark,
      lesson_date: summary.lesson_date,
      lesson_url: lesson ? lesson_url(lesson) : nil
    }
  end
end