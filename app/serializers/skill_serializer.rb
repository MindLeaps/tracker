# frozen_string_literal: true

class SkillSerializer < ActiveModel::Serializer
  attributes :id, :skill_name, :skill_description, :organization_id, :deleted_at

  belongs_to :organization
  has_many :subjects
  has_many :grade_descriptors
end
