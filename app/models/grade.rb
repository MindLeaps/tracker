# frozen_string_literal: true
class Grade < ApplicationRecord
  validates :lesson, :student, :grade_descriptor, presence: true
  validate :grade_skill_must_be_unique_for_lesson_and_student, if: :all_relations_exist?

  belongs_to :lesson
  belongs_to :student
  belongs_to :grade_descriptor

  attr_accessor :skill

  def skill
    grade_descriptor.try(:skill) || @skill
  end

  def update_grade_descriptor(new_grade_descriptor)
    if new_grade_descriptor.nil?
      Grade.find(id).delete
    elsif grade_descriptor.id != new_grade_descriptor.id
      self.grade_descriptor = new_grade_descriptor
      save
    end
    self
  end

  private

  def grade_skill_must_be_unique_for_lesson_and_student
    existing_grade = duplicate_grade
    add_duplicate_grade_error(existing_grade) if existing_grade && existing_grade.id != id
  end

  def all_relations_exist?
    [lesson, student, grade_descriptor].exclude? nil
  end

  def duplicate_grade
    Grade.joins(:grade_descriptor)
         .find_by(student: student, lesson: lesson, grade_descriptors: { skill_id: grade_descriptor.skill.id })
  end

  def add_duplicate_grade_error(duplicate_grade)
    errors.add(:grade_descriptor, I18n.translate(:duplicate_grade,
                                                 name: student.proper_name,
                                                 mark: duplicate_grade.grade_descriptor.mark,
                                                 skill: grade_descriptor.skill.skill_name,
                                                 date: lesson.date,
                                                 subject: lesson.subject.subject_name))
  end
end
