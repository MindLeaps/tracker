# frozen_string_literal: true

# == Schema Information
#
# Table name: skills
#
#  id                :integer          not null, primary key
#  deleted_at        :datetime
#  skill_description :text
#  skill_name        :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organization_id   :integer          not null
#
# Indexes
#
#  index_skills_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  skills_organization_id_fk  (organization_id => organizations.id)
#
class SkillSerializer < ActiveModel::Serializer
  attributes :id, :skill_name, :skill_description, :organization_id, :deleted_at

  belongs_to :organization
  has_many :subjects
  has_many :grade_descriptors
end
