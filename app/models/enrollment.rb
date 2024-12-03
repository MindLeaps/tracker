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
  belongs_to :student
  belongs_to :group

  scope :by_student, ->(student_id) { where student_id: }
  scope :by_group, ->(group_id) { where group_id: }

  def organization
    group.chapter.organization
  end
end
