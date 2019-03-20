# frozen_string_literal: true

class GradeSerializerV2 < ActiveModel::Serializer
  attribute :lesson_uid, key: :lesson_id
  attributes :student_id, :deleted_at, :skill_id, :mark

  belongs_to :student
  belongs_to :lesson
  belongs_to :grade_descriptor
end
