# frozen_string_literal: true
class LessonSerializer < ActiveModel::Serializer
  attributes :id, :group_id, :subject_id, :date

  # belongs_to :skill
end
