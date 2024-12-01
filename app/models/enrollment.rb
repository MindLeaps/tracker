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
  validates :student, uniqueness: { scope: :group_id, conditions: -> { where(inactive_since: nil) }, message: I18n.t(:enrollment_duplicate) }
end
