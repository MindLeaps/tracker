class GroupReportsController < HtmlController
  include CollectionHelper

  skip_after_action :verify_policy_scoped
  layout 'print'
  def show
    @group = Group.find params[:id]
    authorize @group

    @enrollments_for_group = Enrollment.where(group_id: @group.id)
    @group_lesson_summaries = group_summaries_for_group.map { |summary| lesson_summary(summary) }
    @student_enrollments_component = TableComponents::Table.new(rows: enrolled_students.sort_by { |e| e[:full_name] }, row_component: TableComponents::StudentEnrollmentReport)
    @enrollment_timelines = @enrollments_for_group.map { |e| enrollment_timeline(e) }
    @reports = []
    populate_reports
  end

  def populate_reports
    grouped_student_summaries = student_row_reports.group_by { |summary| summary[:subject_id] }

    @group_lesson_summaries.group_by { |summary| summary[:subject_id] }.each do |subject_id, summaries|
      report_to_add = {}
      report_to_add[:subject_id] = subject_id
      report_to_add[:subject_name] = Subject.find(subject_id).subject_name
      report_to_add[:group_summaries] = summaries
      report_to_add[:student_summaries] = grouped_student_summaries[subject_id].sort_by { |e| e[:last_name] }

      @reports.push(report_to_add)
    end
  end

  def enrolled_students
    enrolled_students = []
    @enrollments_for_group.each do |enrollment|
      multiple_enrollments = @enrollments_for_group.where(student_id: enrollment.student_id).order(active_since: :asc)

      if multiple_enrollments.many?
        enrolled_students.push(student_details(single_enrollment(multiple_enrollments)))
        next
      end

      enrolled_students.push(student_details(enrollment))
    end

    enrolled_students
  end

  def enrollment_timeline(enrollment)
    {
      student_id: enrollment.student_id,
      student_name: Student.find_by(id: enrollment.student_id).proper_name,
      active_since: enrollment.active_since&.iso8601,
      inactive_since: enrollment.inactive_since&.iso8601,
      effective_end: enrollment_end(enrollment)&.iso8601
    }
  end

  def enrollment_end(enrollment)
    return enrollment.inactive_since if enrollment.inactive_since.present?
    return Time.zone.now if @group_lesson_summaries.empty?
    return Time.zone.now if @group_lesson_summaries.last && (enrollment.active_since.to_date > @group_lesson_summaries.last&.[](:lesson_date))

    @group_lesson_summaries.last&.[](:lesson_date)
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
    { lesson_date: summary.lesson_date, average_mark: summary.average_mark, attendance: summary.attendance, subject_id: summary.subject_id, lesson_url: lesson_path(summary.lesson_id) }
  end

  def student_row_reports
    student_summaries = StudentLessonSummary.where(group_id: @group.id)
    students = student_summaries.pluck(:student_id, :first_name, :last_name, :subject_id).uniq
    students.map do |student|
      summaries_for_student = student_summaries.where(student_id: student[0], subject_id: student[3]).where.not(grade_count: 0).order(lesson_date: :asc)

      {
        first_name: student[1],
        last_name: student[2],
        first_lesson: summaries_for_student.first&.average_mark,
        middle_lesson: middle_from_rel(summaries_for_student)&.average_mark,
        last_lesson: summaries_for_student.last&.average_mark,
        subject_id: summaries_for_student.first&.subject_id
      }
    end
  end
end
