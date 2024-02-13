# frozen_string_literal: true

# == Schema Information
#
# Table name: chapters
#
#  id              :integer          not null, primary key
#  chapter_name    :string           not null
#  deleted_at      :datetime
#  mlid            :string(2)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#
# Indexes
#
#  index_chapters_on_organization_id  (organization_id)
#  unique_mlid_per_scope              (mlid,organization_id) UNIQUE
#
# Foreign Keys
#
#  chapters_organization_id_fk  (organization_id => organizations.id)
#
class Chapter < ApplicationRecord
  validates :chapter_name, presence: true
  validates :chapter_name, uniqueness: {
    scope: :organization_id,
    message: lambda do |chapter, data|
      "Chapter \"#{data[:value]}\" already exists in #{chapter.organization_name} organization"
    end
  }
  validates :mlid, presence: true, uniqueness: { scope: :organization_id }, format: { with: /\A[A-Za-z0-9]+\Z/ }

  belongs_to :organization
  has_many :groups, dependent: :restrict_with_error
  has_many :students, dependent: :restrict_with_error

  delegate :organization_name, to: :organization, allow_nil: true

  scope :by_organization, ->(organization_id) { where organization_id: }

  def display_with_mlid
    I18n.t(:display_with_mlid, name: chapter_name, mlid: full_mlid)
  end

  def full_mlid
    "#{organization.mlid}-#{mlid}"
  end
end
