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
class EnrollmentSerializer < ActiveModel::Serializer
  attributes :id, :active_since, :inactive_since, :created_at, :updated_at, :group_id, :student_id

  belongs_to :student
  belongs_to :group

  def active_since
    object.active_since.to_datetime.iso8601
  end

  def inactive_since
    object.inactive_since.present? ? object.inactive_since.to_datetime.iso8601 : nil
  end
end
