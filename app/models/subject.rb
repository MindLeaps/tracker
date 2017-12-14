# frozen_string_literal: true

class Subject < ApplicationRecord
  belongs_to :organization
  has_many :lessons, dependent: :restrict_with_error
  has_many :assignments, -> { exclude_deleted }, inverse_of: :subject, dependent: :destroy
  has_many :skills, through: :assignments, dependent: :destroy, inverse_of: :subjects

  validates :subject_name, :organization, presence: true

  scope :by_organization, ->(organization_id) { where organization_id: organization_id }

  accepts_nested_attributes_for :assignments, allow_destroy: true
end
