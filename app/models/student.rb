# frozen_string_literal: true
class Student < ActiveRecord::Base
  validates :mlid, :first_name, :last_name, :dob, :gender, :organization, presence: true
  validates :mlid, uniqueness: {
    scope: :organization_id
  }
  belongs_to :group
  belongs_to :organization
  enum gender: { M: 0, F: 1 }
  has_many :grades
  accepts_nested_attributes_for :grades

  delegate :group_name, to: :group, allow_nil: true

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def self.permitted_params
    [:mlid, :first_name, :last_name, :dob, :estimated_dob, :group_id, :gender, :quartier,
     :guardian_name, :guardian_occupation, :guardian_contact, :family_members, :health_insurance,
     :health_issues, :hiv_tested, :name_of_school, :school_level_completed, :year_of_dropout,
     :reason_for_leaving, :notes, :organization_id]
  end

  def grades_for_lesson(lesson_id)
    lesson = Lesson.find lesson_id
    skills = lesson.subject.skills

    skill_grades = Hash[skills.map { |skill| [skill.id, Grade.new(lesson_id: lesson_id, student_id: id, skill: skill)] }]

    Grade.where(lesson_id: lesson_id, student_id: id).find_each { |grade| skill_grades[grade.skill.id] = grade }

    skill_grades.values
  end

  def grade_lesson(lesson_id, new_grades)
    existing_grades = Grade.where(lesson_id: lesson_id, student_id: id).includes(:grade_descriptor).all.to_a
    new_grades.map do |grade|
      update_grade grade, existing_grade(grade, existing_grades)
    end
  end

  private

  def update_grade(grade, existing_grade)
    return existing_grade.update_grade_descriptor grade.grade_descriptor if existing_grade
    grade.tap(&:save)
  end

  def existing_grade(new_grade, existing_grades)
    existing_grades.find { |g| g.id == new_grade.id }
  end
end
