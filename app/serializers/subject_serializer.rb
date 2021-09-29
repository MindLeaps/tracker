# frozen_string_literal: true

# == Schema Information
#
# Table name: subjects
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  subject_name    :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer          not null
#
# Indexes
#
#  index_subjects_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  subjects_organization_id_fk  (organization_id => organizations.id)
#
class SubjectSerializer < ActiveModel::Serializer
  attributes :id, :subject_name, :organization_id, :deleted_at

  belongs_to :organization
  has_many :lessons
  has_many :skills
end
