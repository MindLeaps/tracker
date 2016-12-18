# frozen_string_literal: true
class Lesson < ApplicationRecord
  belongs_to :group
  belongs_to :subject
  has_many :absences

  validates :group, :date, :subject, presence: true
  validates :date, uniqueness: {
    scope: [:group, :subject],
    message: ->(object, _data) { I18n.translate :duplicate_lesson, group: object.group.group_name, subject: object.subject.subject_name }
  }

  scope :by_group, ->(group_id) { where group_id: group_id }
  scope :by_subject, ->(subject_id) { where subject_id: subject_id }
end
