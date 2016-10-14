# frozen_string_literal: true
class GradeSerializer < ActiveModel::Serializer
  attributes :id, :student_id, :lesson_id, :grade_descriptor_id, :deleted_at

  belongs_to :student
  belongs_to :lesson
  belongs_to :grade_descriptor
end
