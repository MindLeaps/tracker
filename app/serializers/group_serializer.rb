# frozen_string_literal: true

class GroupSerializer < ActiveModel::Serializer
  attributes :id, :group_name, :chapter_id, :deleted_at

  belongs_to :chapter
  has_many :students
  has_many :lessons
end
