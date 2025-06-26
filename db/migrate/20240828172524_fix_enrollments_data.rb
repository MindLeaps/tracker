class FixEnrollmentsData < ActiveRecord::Migration[7.1]
  def up
    Enrollment.pluck(:student_id).each do |id|
      if more_than_one_enrollment_for_student?(id)
        update_enrollments_for_student(id)
      else
        enrollment = Enrollment.find_by(student_id: id)
        enrollment.update(inactive_since: nil) unless enrollment.inactive_since.nil?
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'This migration cannot be reverted because it amends data.'
  end

  def more_than_one_enrollment_for_student?(id)
    Enrollment.where(student_id: id).many?
  end

  def update_enrollments_for_student(id)
    sorted_enrollments = Enrollment.where(student_id: id).order(:active_since)

    sorted_enrollments.each_with_index do |enrollment, i|
      next if enrollment.inactive_since.nil?

      if enrollment == sorted_enrollments.last
        enrollment.update(inactive_since: nil)
        next
      end

      next_enrollment = sorted_enrollments[i + 1]

      lessons_in_between = lessons_between_enrollments(enrollment, next_enrollment)

      if lessons_in_between.empty?
        enrollment.update(inactive_since: next_enrollment.active_since - 1.day)
      else
        enrollment.update(inactive_since: lessons_in_between.last.date)
      end
    end
  end

  def lessons_between_enrollments(enrollment, next_enrollment)
    Lesson.where(group_id: enrollment.group_id).where(date: enrollment.active_since...next_enrollment.active_since).order(:date)
  end
end
