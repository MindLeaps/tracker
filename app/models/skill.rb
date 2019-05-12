# frozen_string_literal: true

class Skill < ApplicationRecord
  include PgSearch
  pg_search_scope :search, against: [:skill_name], using: { tsearch: { prefix: true } }

  validates :skill_name, :organization, presence: true
  validate :grade_descriptors_must_have_unique_marks

  belongs_to :organization
  has_many :grade_descriptors, dependent: :destroy, inverse_of: :skill
  has_many :assignments, dependent: :destroy
  has_many :subjects, through: :assignments, dependent: :restrict_with_error, inverse_of: :skills

  scope :by_organization, ->(organization_id) { where organization_id: organization_id }

  scope :by_subject, ->(subject_id) { joins(:assignments).where(assignments: { subject_id: subject_id }) }

  accepts_nested_attributes_for :grade_descriptors, update_only: true

  def grade_descriptors_must_have_unique_marks
    return if grade_descriptors.empty?
    return unless duplicates? grade_descriptors.map(&:mark)

    errors.add :grade_descriptors, 'Grade Descriptors cannot have duplicate marks.'
  end

  private

  def duplicates?(arr)
    arr.uniq.length != arr.length
  end
end
