# frozen_string_literal: true

class GradeDescriptorSerializer < ActiveModel::Serializer
  attributes :id, :mark, :grade_description, :skill_id, :deleted_at

  belongs_to :skill
end
