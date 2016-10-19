# frozen_string_literal: true
class AssignmentSerializer < ActiveModel::Serializer
  attributes :id, :skill_id, :subject_id

  belongs_to :skill
  belongs_to :subject
end
