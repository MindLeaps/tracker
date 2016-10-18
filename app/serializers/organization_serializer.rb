# frozen_string_literal: true
class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :organization_name, :image, :deleted_at
end
