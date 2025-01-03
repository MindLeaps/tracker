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

  scope :by_organization, ->(organization_id) { where organization_id: }

  accepts_nested_attributes_for :assignments, allow_destroy: true

  def grades_in_skill?(skill_id)
    lessons.joins(:grades).exists?(grades: { skill_id: })
  end

  def graded_skill_name
    removed_skill_ids = assignments.filter(&:marked_for_destruction?).map(&:skill_id)
    removed_skill_ids.each { |id| return Skill.find(id).skill_name if grades_in_skill?(id) }
    false
  end

  def duplicate_skills?
    assignments.map(&:skill_id).uniq.length != assignments.length
  end
end
