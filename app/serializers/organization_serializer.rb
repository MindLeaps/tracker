# frozen_string_literal: true
class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :organization_name, :image, :deleted_at

  has_many :chapters
  has_many :students
end
