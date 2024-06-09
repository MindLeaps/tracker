class GradeSerializerV2 < ActiveModel::Serializer
  attributes :lesson_id, :student_id, :deleted_at, :skill_id, :mark

  belongs_to :student
  belongs_to :lesson
  belongs_to :grade_descriptor
end
