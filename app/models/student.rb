# frozen_string_literal: true
class Student < ApplicationRecord
  validates :mlid, :first_name, :last_name, :dob, :gender, :organization, presence: true
  validates :mlid, uniqueness: {
    scope: :organization_id
  }
  enum gender: { M: 0, F: 1 }
  belongs_to :group
  belongs_to :organization
  has_many :grades
  has_many :absences
  has_many :student_images
  accepts_nested_attributes_for :grades
  accepts_nested_attributes_for :student_images

  delegate :group_name, to: :group, allow_nil: true

  scope :by_group, ->(group_id) { where group_id: group_id }

  scope :by_organization, ->(organization_id) { where organization_id: organization_id }

  def proper_name
    "#{last_name}, #{first_name}"
  end

  def self.permitted_params
    [:mlid, :first_name, :last_name, :dob, :estimated_dob, :group_id, :gender, :quartier,
     :guardian_name, :guardian_occupation, :guardian_contact, :family_members, :health_insurance,
     :health_issues, :hiv_tested, :name_of_school, :school_level_completed, :year_of_dropout,
     :reason_for_leaving, :notes, :organization_id, student_images_attributes: [:filename]]
  end

  def current_grades_for_lesson_including_ungraded_skills(lesson_id)
    lesson = Lesson.find lesson_id
    skills = lesson.subject.skills

    skill_grades = Hash[skills.map { |skill| [skill.id, Grade.new(lesson_id: lesson_id, student_id: id, skill: skill)] }]

    current_grades_for_lesson(lesson_id).find_each { |grade| skill_grades[grade.skill.id] = grade }

    skill_grades.values
  end

  def grade_lesson(lesson_id, new_grades)
    existing_grades = Grade.where(lesson_id: lesson_id, student_id: id).includes(:grade_descriptor).all.to_a
    new_grades.map do |grade|
      update_grade grade, existing_grade(grade, existing_grades)
    end
  end

  private

  def current_grades_for_lesson(lesson_id)
    Grade.where(lesson_id: lesson_id, student_id: id).exclude_deleted
  end

  def update_grade(grade, existing_grade)
    return existing_grade.update_grade_descriptor grade.grade_descriptor if existing_grade
    grade.tap(&:save)
  end

  def existing_grade(new_grade, existing_grades)
    existing_grades.find { |g| g.id == new_grade.id }
  end
end
