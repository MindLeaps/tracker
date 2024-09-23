class GroupReportsController < HtmlController
  include CollectionHelper
  skip_after_action :verify_policy_scoped
  layout 'print'
  def show
    @group = Group.find params[:id]
    authorize @group

    @enrollments_for_group = Enrollment.where(group_id: @group.id)
    @group_lesson_summaries = group_summaries_for_group.map { |summary| lesson_summary(summary) }
    @student_lesson_summaries = StudentLessonSummary.where(group_id: @group.id).order(lesson_date: :asc)
    @student_summaries_component = TableComponents::Table.new(rows: student_row_reports.sort_by { |e| e[:last_name] }, row_component: TableComponents::StudentRowReport)
    @student_enrollments_component = TableComponents::Table.new(rows: enrolled_students.sort_by { |e| e[:full_name] }, row_component: TableComponents::StudentEnrollmentReport)
    @enrollment_timelines = []
  end

  def enrollment_timelines
    datasets = []

    student_ids = @enrollments_for_group.pluck(:student_id).uniq

    student_ids.each do |id|
      dataset = { name: Student.find_by(id: id).proper_name, data: [] }
      single_student_enrollments_ascending = @enrollments_for_group.where(student_id: id).order(active_since: :asc)

      single_student_enrollments_ascending.each do |s|
        dataset[:data].push({ student_id: id, date: s.active_since })

        if s.inactive_since.present?
          dataset[:data].push({ student_id: id, date: s.inactive_since })
          dataset[:data].push({ student_id: id, date: nil })
        end
      end

      dataset[:data].push({ student_id: id, date: Time.now }) if single_student_enrollments_ascending.last.inactive_since.blank?

      datasets.push(dataset)
    end

    datasets
  end

  def enrolled_students
    enrolled_students = []
    @enrollments_for_group.each do |enrollment|
      multiple_enrollments = @enrollments_for_group.where(student_id: enrollment.student_id).order(active_since: :asc)

      if multiple_enrollments.count > 1
        enrolled_students.push(student_details(single_enrollment(multiple_enrollments)))
        next
      end

      enrolled_students.push(student_details(enrollment))
    end

    enrolled_students
  end

  def single_enrollment(multiple_enrollments)
    Enrollment.new(
      student_id: multiple_enrollments.last.student_id,
      active_since: multiple_enrollments.first.active_since,
      inactive_since: multiple_enrollments.last.inactive_since
    )
  end

  def student_details(enrollment)
    student = Student.find_by(id: enrollment.student_id)

    {
      mlid: "#{@group.full_mlid}-#{student.mlid}",
      full_name: student.proper_name,
      gender: student.gender,
      dob: student.dob,
      join_date: enrollment.active_since.to_date,
      leave_date: enrollment.inactive_since&.to_date
    }
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
