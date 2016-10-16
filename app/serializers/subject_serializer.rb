# frozen_string_literal: true
class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :subject_name, :organization_id, :deleted_at

  belongs_to :organization
  has_many :lessons
  has_many :skills
end
