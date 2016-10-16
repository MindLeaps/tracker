# frozen_string_literal: true
class GradeDescriptorSerializer < ActiveModel::Serializer
  attributes :id, :mark, :grade_description
end
