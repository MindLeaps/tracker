# == Schema Information
#
# Table name: enrollments
#
#  id             :uuid             not null, primary key
#  active_since   :datetime         not null
#  inactive_since :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  group_id       :bigint           not null
#  student_id     :bigint           not null
#
# Indexes
#
#  index_enrollments_on_group_id    (group_id)
#  index_enrollments_on_student_id  (student_id)
#  non_overlapping_enrollments      (student_id, group_id, tsrange(active_since, inactive_since)) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups.id) ON DELETE => cascade
#  fk_rails_...  (student_id => students.id) ON DELETE => cascade
#
class Enrollment < ApplicationRecord
  belongs_to :student, inverse_of: :enrollments
  belongs_to :group, inverse_of: :enrollments

  validates :active_since, presence: true
  validates :inactive_since, comparison: { greater_than: :active_since, message: I18n.t(:enrollment_end_before_start) }, allow_nil: true
  validates :student, uniqueness: { scope: [:group_id, :inactive_since], message: I18n.t(:enrollment_duplicate), if: :open? }
  validate :validate_student_and_group_in_same_org
  validate :validate_enrollments_do_not_overlap

  def chapter_group_name_with_full_mlid
    "#{group.chapter_name} - #{group.group_name}: #{group.full_mlid}"
  end

  def validate_student_and_group_in_same_org
    errors.add(:student, I18n.t(:enrollment_not_same_org)) if student.present? && group.present? && student.organization_id != (group.chapter.organization_id)
  end

  def validate_enrollments_do_not_overlap
    errors.add(:student, I18n.t(:enrollment_overlap)) if student.present? && group.present? && overlapping_enrollment?
  end

  def open?
    inactive_since.nil?
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
