# == Schema Information
#
# Table name: lessons
#
#  id         :integer          not null, primary key
#  date       :date             not null
#  deleted_at :datetime
#  uid        :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer          not null
#  subject_id :integer          not null
#
# Indexes
#
#  index_lessons_on_group_id                          (group_id)
#  index_lessons_on_group_id_and_subject_id_and_date  (group_id,subject_id,date) UNIQUE WHERE (deleted_at IS NULL)
#  index_lessons_on_subject_id                        (subject_id)
#  index_lessons_on_uid                               (uid) UNIQUE
#  lesson_uuid_unique                                 (uid) UNIQUE
#
# Foreign Keys
#
#  lessons_group_id_fk    (group_id => groups.id)
#  lessons_subject_id_fk  (subject_id => subjects.id)
#
class Lesson < ApplicationRecord
  belongs_to :group
  belongs_to :subject
  has_many :absences, dependent: :restrict_with_error
  has_many :grades, dependent: :restrict_with_error

  validates :date, presence: true
  scope :by_group, ->(group_id) { where group_id: }
  scope :by_subject, ->(subject_id) { where subject_id: }

  validates :date, uniqueness: {
    scope: %i[group subject],
    message: ->(object, _data) { I18n.t :duplicate_lesson, group: object.group.group_name, subject: object.subject.subject_name }
  }

  def mark_student_as_absent(student)
    return if student_absent?(student)

    Absence.create student:, lesson: self
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
