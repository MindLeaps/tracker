# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  deleted_at        :datetime
#  image             :string           default("https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200")
#  mlid              :string(3)        not null
#  organization_name :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  organizations_mlid_key  (mlid) UNIQUE
#
class OrganizationSerializer < ActiveModel::Serializer
  attributes :id, :organization_name, :image, :deleted_at

  has_many :chapters
  has_many :students
end
