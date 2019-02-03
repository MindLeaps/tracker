# frozen_string_literal: true

class LessonSerializerUUID < ActiveModel::Serializer
  attribute :uid, key: :id
  attributes :group_id, :subject_id, :date, :deleted_at

  belongs_to :group
  belongs_to :subject
end
