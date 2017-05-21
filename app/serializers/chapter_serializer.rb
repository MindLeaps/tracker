# frozen_string_literal: true

class ChapterSerializer < ActiveModel::Serializer
  attributes :id, :chapter_name, :organization_id

  belongs_to :organization
  has_many :groups
end
