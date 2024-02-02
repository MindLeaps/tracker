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
class Subject < ApplicationRecord
  singleton_class.send(:alias_method, :table_order_subjects, :table_order)
  belongs_to :organization
  has_many :lessons, dependent: :restrict_with_error
  has_many :assignments, -> { exclude_deleted }, inverse_of: :subject, dependent: :destroy
  has_many :skills, through: :assignments, dependent: :destroy, inverse_of: :subjects

  validates :subject_name, presence: true

  scope :by_organization, ->(organization_id) { where organization_id: organization_id }

  accepts_nested_attributes_for :assignments, allow_destroy: true
end
