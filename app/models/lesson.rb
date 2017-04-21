# frozen_string_literal: true
class Lesson < ApplicationRecord
  belongs_to :group
  belongs_to :subject
  has_many :absences
  has_many :grades

  validates :group, :date, :subject, presence: true
  scope :by_group, ->(group_id) { where group_id: group_id }
  scope :by_subject, ->(subject_id) { where subject_id: subject_id }

  validates :date, uniqueness: {
    scope: [:group, :subject],
    message: ->(object, _data) { I18n.translate :duplicate_lesson, group: object.group.group_name, subject: object.subject.subject_name }
  }

  def mark_student_as_absent(student)
    return if student_absent?(student)

    Absence.create student: student, lesson: self
  end

  def mark_student_as_present(student)
    return unless student_absent? student

    absence = absences.detect { |a| a.student_id == student.id }
    absence.destroy
  end

  def student_absent?(student)
    absences.any? { |absence| absence.student_id == student.id }
  end
end
