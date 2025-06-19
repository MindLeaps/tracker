# == Schema Information
#
# Table name: enrollments
#
#  id             :uuid             not null, primary key
#  active_since   :date             not null
#  inactive_since :date
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_id       :bigint           not null
#  student_id     :bigint           not null
#
# Indexes
#
#  index_enrollments_on_group_id    (group_id)
#  index_enrollments_on_student_id  (student_id)
#  non_overlapping_enrollments      (student_id, group_id, tsrange((active_since)::timestamp without time zone, (inactive_since)::timestamp without time zone)) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id) ON DELETE => cascade
#  fk_rails_...  (student_id => students.id) ON DELETE => cascade
#
class Enrollment < ApplicationRecord
  belongs_to :student, inverse_of: :enrollments
  belongs_to :group, inverse_of: :enrollments

  scope :by_student, ->(student_id) { where student_id: }
  scope :by_group, ->(group_id) { where group_id: }

  validates :active_since, presence: true
  validates :inactive_since, comparison: { greater_than: :active_since, message: I18n.t(:enrollment_end_before_start) }, allow_nil: true
  validates :student, uniqueness: { scope: [:group_id, :inactive_since], message: I18n.t(:enrollment_duplicate), if: :open? }
  validate :validate_student_and_group_in_same_org, if: :student_in_organization?
  validate :validate_enrollments_do_not_overlap
  validate :validate_group_has_not_changed
  validate :validate_modified_enrollment_does_not_lose_grades

  def student_in_organization?
    student.organization.present?
  end

  def validate_student_and_group_in_same_org
    errors.add(:student, I18n.t(:enrollment_not_same_org)) if student.present? && group.present? && (student.organization_id != group.chapter.organization_id)
  end

  def chapter_group_name_with_full_mlid
    "#{group.chapter_name} - #{group.group_name}: #{group.full_mlid}"
  end

  def organization
    group.chapter.organization
  end

  def validate_enrollments_do_not_overlap
    errors.add(:student, I18n.t(:enrollment_overlap)) if student.present? && group.present? && overlapping_enrollment?
  end

  def open?
    inactive_since.nil?
  end

  def validate_deleted_enrollment_has_no_grades
    lessons = Lesson.where(group_id: group_id)
    grades = Grade.where(student_id: student_id, lesson_id: lessons, deleted_at: nil)

    if grades.count.positive?
      errors.add(:student, I18n.t(:enrollment_not_deleted_because_grades)) if grades.count.positive?
      throw :abort
    end
  end

  def validate_group_has_not_changed
    original_enrollment = Enrollment.find_by(id: id)

    errors.add(:student, I18n.t(:cannot_change_existing_enrollment)) if original_enrollment.present? && original_enrollment.group_id != group_id
  end

  def validate_modified_enrollment_does_not_lose_grades
    original_enrollment = Enrollment.find_by(id: id)
    if original_enrollment.present?
      lessons = Lesson.where(group_id: original_enrollment.group_id)
      all_grades = Grade.where(student_id: original_enrollment.student_id, lesson_id: lessons, deleted_at: nil)

      if active_since != original_enrollment.active_since || inactive_since != original_enrollment.inactive_since
        current_grades = Grade.where(student_id: student_id, lesson_id: lessons, deleted_at: nil, created_at: active_since..inactive_since)

        errors.add(:student, I18n.t(:cannot_change_enrollment_dates_because_grades)) if current_grades.count != all_grades.count
      end
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def overlapping_enrollment?
    Enrollment.excluding(self).exists?(student_id: student.id, group_id: group.id, active_since: active_since..inactive_since) ||
      Enrollment.excluding(self).exists?(student_id: student.id, group_id: group.id, inactive_since: active_since..inactive_since) ||
      (inactive_since.present? && Enrollment.excluding(self).exists?(student_id: student.id, group_id: group.id, active_since: ..active_since, inactive_since: inactive_since..)) ||
      Enrollment.excluding(self).exists?(student_id: student.id, group_id: group.id, active_since: ..active_since, inactive_since: nil)
  end
  # rubocop:enable Metrics/AbcSize
end
