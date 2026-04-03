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
    @performance_per_skill = performance_per_skill_single_student
  end

  private

  def fetch_performance_changes_by_subject(student_id)
    sql = Sql.performance_change_summary_with_middle_by_subject_query([student_id])
    ActiveRecord::Base.connection.exec_query(sql).to_a.map(&:symbolize_keys)
  end

  # rubocop:disable Metrics/MethodLength
  def skill_average_summaries
    grouped = {}

    StudentAverage.where(student_id: @student.id).load.each do |average|
      subject_name = average[:subject_name].to_s
      grouped[subject_name] ||= []
      grouped[subject_name] << {
        skill: average[:skill_name],
        average: average[:average_mark].to_f
      }
    end

    grouped.transform_values do |rows|
      strongest = rows.max_by { |row| row[:average] }
      weakest = rows.min_by { |row| row[:average] }
      sorted_skills = rows.sort_by { |row| -row[:average] }

      {
        strongest: strongest,
        weakest: weakest,
        skills: sorted_skills
      }
    end
  end
  # rubocop:enable Metrics/MethodLength

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

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def performance_per_skill_single_student
    conn = ActiveRecord::Base.connection.raw_connection
    student_name = @student.proper_name

    sql = Sql.performance_per_skill_in_lessons_per_student_query_with_dates([@student.id])
    rows = conn.exec_params(sql, [nil, nil]).values

    grouped = rows.each_with_object({}) do |row, acc|
      lesson_index = row[0].to_i + 1
      average_mark = row[1].to_f
      lesson_id = row[2]
      lesson_date = row[3]
      skill_name = row[4]

      acc[skill_name] ||= []
      acc[skill_name] << {
        x: lesson_index,
        y: average_mark,
        lesson_url: lesson_path(lesson_id),
        date: lesson_date
      }
    end

    grouped.map.with_index do |(skill_name, data), index|
      {
        skill: skill_name,
        series: [
          {
            name: student_name,
            data: data,
            color: get_color(index)
          }
        ]
      }
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def colors
    %w[#7cb5ec #434348 #90ed7d #f7a35c #8085e9 #f15c80 #e4d354 #2b908f #f45b5b #91e8e1]
  end

  def get_color(index)
    colors[index % colors.length]
  end
end
