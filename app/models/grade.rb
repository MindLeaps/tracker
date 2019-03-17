# frozen_string_literal: true

class Grade < ApplicationRecord
  before_validation :update_uids
  validates :lesson, :lesson_uid, :student, :grade_descriptor, :skill, presence: true
  validate :grade_skill_must_be_unique_for_lesson_and_student, if: :all_relations_exist?

  belongs_to :lesson
  belongs_to :student
  belongs_to :grade_descriptor
  belongs_to :skill

  scope :by_student, ->(student_id) { where student_id: student_id }

  scope :by_lesson, ->(lesson_id) { where lesson_id: lesson_id }

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
         .where(student: student, lesson: lesson, grade_descriptors: { skill_id: grade_descriptor.skill.id })
         .where.not(id: id)
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
    errors.add(:grade_descriptor, I18n.translate(:duplicate_grade,
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

  def update_uids
    self.lesson_uid = lesson&.reload&.uid
  end
end
