class EnrollmentSerializerV2 < ActiveModel::Serializer
  attributes :id, :active_since, :inactive_since, :created_at, :updated_at, :group_id, :student_id

  belongs_to :student
  belongs_to :group
end
