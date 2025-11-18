# == Schema Information
#
# Table name: tags
#
#  id                      :uuid             not null, primary key
#  shared                  :boolean          not null
#  shared_organization_ids :bigint           default([]), is an Array
#  tag_name                :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :bigint           not null
#
# Indexes
#
#  index_tags_on_organization_id  (organization_id)
#
class Tag < ApplicationRecord
  has_many :student_tags, dependent: :destroy
  has_many :students, through: :student_tags
  belongs_to :organization

  validates :tag_name, presence: true
  validates :tag_name, uniqueness: {
    scope: :organization_id,
    message: lambda do |tag, data|
      "Tag \"#{data[:value]}\" already exists in #{Organization.find(tag.organization_id).organization_name} organization"
    end
  }
  validate :no_duplicate_shared_organization_ids
  validate :shared_organization_ids_exist

  def no_duplicate_shared_organization_ids
    errors.add(:shared_organization_ids, 'must contain only unique values') if shared_organization_ids.any? && shared_organization_ids.uniq.length != shared_organization_ids.length
  end

  def shared_organization_ids_exist
    errors.add(:shared_organization_ids, 'Organization selected must exist') if shared_organization_ids.any? { |id| !Organization.exists?(id) }
  end

  def can_delete?
    students.none?
  end
end
