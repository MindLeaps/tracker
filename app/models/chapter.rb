# frozen_string_literal: true
class Chapter < ApplicationRecord
  validates :chapter_name, presence: true
  validates :organization, presence: true, unless: -> (chapter) { chapter.organization_id.nil? }
  validates :chapter_name, uniqueness: {
    scope: :organization_id,
    message: lambda do |chapter, data|
      "Chapter \"#{data[:value]}\" already exists in #{chapter.organization_name} organization"
    end
  }

  belongs_to :organization
  has_many :groups
  has_many :students

  delegate :organization_name, to: :organization, allow_nil: true

  scope :by_organization, ->(organization_id) { where organization_id: organization_id }
end
