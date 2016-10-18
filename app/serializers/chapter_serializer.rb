# frozen_string_literal: true
class ChapterSerializer < ActiveModel::Serializer
  attributes :id, :chapter_name, :organization_id
end
