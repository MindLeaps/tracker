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
class Skill < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search, against: [:skill_name], using: { tsearch: { prefix: true } }
  singleton_class.send(:alias_method, :table_order_skills, :table_order)

  validates :skill_name, presence: true
  validate :grade_descriptors_must_have_unique_marks

  belongs_to :organization
  has_many :grade_descriptors, dependent: :destroy, inverse_of: :skill
  has_many :assignments, dependent: :destroy
  has_many :subjects, through: :assignments, dependent: :restrict_with_error, inverse_of: :skills

  scope :by_organization, ->(organization_id) { where organization_id: }

  scope :by_subject, ->(subject_id) { joins(:assignments).where(assignments: { subject_id: }) }

  accepts_nested_attributes_for :grade_descriptors, update_only: true

  def grade_descriptors_must_have_unique_marks
    return if grade_descriptors.empty?
    return unless duplicates? grade_descriptors.map(&:mark)

    errors.add :grade_descriptors, 'Grade Descriptors cannot have duplicate marks.'
  end

  def can_delete?
    subjects.none? && Grade.where(skill: self, deleted_at: nil).none?
  end

  private

  def duplicates?(arr)
    arr.uniq.length != arr.length
  end
end
