# == Schema Information
#
# Table name: grades
#
#  id                  :integer          not null, primary key
#  deleted_at          :datetime
#  mark                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  grade_descriptor_id :integer          not null
#  lesson_id           :uuid             not null
#  old_lesson_id       :integer          not null
#  skill_id            :bigint           not null
#  student_id          :integer          not null
#
# Indexes
#
#  index_grades_on_grade_descriptor_id  (grade_descriptor_id)
#  index_grades_on_lesson_id            (lesson_id)
#  index_grades_on_skill_id             (skill_id)
#  index_grades_on_student_id           (student_id)
#
# Foreign Keys
#
#  fk_rails_...                   (skill_id => skills.id)
#  grades_grade_descriptor_id_fk  (grade_descriptor_id => grade_descriptors.id)
#  grades_lesson_id_fk            (lesson_id => lessons.id)
#  grades_student_id_fk           (student_id => students.id)
#
class Grade < ApplicationRecord
  before_validation :update_lesson_ids
  validate :grade_skill_must_be_unique_for_lesson_and_student, if: :all_relations_exist?

  belongs_to :lesson
  belongs_to :student
  belongs_to :grade_descriptor
  belongs_to :skill

  scope :by_student, ->(student_id) { where student_id: }

  scope :by_lesson, ->(lesson_id) { where lesson_id: }

  scope :exclude_deleted_students, -> { joins(:student).where students: { deleted_at: nil } }

  def grade_descriptor=(new_grade_descriptor)
    unless new_grade_descriptor.nil?
      self.skill_id = new_grade_descriptor.skill_id
      self.mark = new_grade_descriptor.mark
    end
    super(new_grade_descriptor)
  end

  def update_grade_descriptor(new_grade_descriptor)
    return mark_grade_as_deleted if new_grade_descriptor.nil?

    if grade_descriptor.id != new_grade_descriptor.id
      self.grade_descriptor = new_grade_descriptor
      save
    end
    self
  end

  def find_duplicate
    Grade.joins(:grade_descriptor)
         .where(student:, lesson:, skill_id:)
         .where.not(id:)
         .take
  end

  private

  def all_relations_exist?
    [lesson, student, grade_descriptor].exclude? nil
  end

  def grade_skill_must_be_unique_for_lesson_and_student
    existing_grade = find_duplicate
    add_duplicate_grade_error(existing_grade) if existing_grade
  end

  def add_duplicate_grade_error(duplicate_grade)
    errors.add(:grade_descriptor, I18n.t(:duplicate_grade,
                                         name: student.proper_name,
                                         mark: duplicate_grade.grade_descriptor.mark,
                                         skill: grade_descriptor.skill.skill_name,
                                         date: lesson.date,
                                         subject: lesson.subject.subject_name))
  end

  def mark_grade_as_deleted
    self.deleted_at = Time.zone.now
    save
    self
  end

  def update_lesson_ids
    self.lesson_id = lesson&.reload&.id
  end
end
