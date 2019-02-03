# frozen_string_literal: true

class GradeSerializerUUID < ActiveModel::Serializer
  attribute :uid, key: :id
  attribute :lesson_uid, key: :lesson_id
  attributes :student_id, :grade_descriptor_id, :deleted_at

  belongs_to :student
  belongs_to :lesson
  belongs_to :grade_descriptor
end
