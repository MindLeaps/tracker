# == Schema Information
#
# Table name: student_lessons
#
#  lesson_id  :integer
#  student_id :integer
#
class StudentLesson < ApplicationRecord
  belongs_to :student
  belongs_to :lesson
  has_one :subject, through: :lesson
  has_many :skills, through: :subject
  has_many :grades, dependent: :restrict_with_error
  accepts_nested_attributes_for :grades

  # Returns Grades with valid grades for graded skills and nulled grades for ungraded skills or deleted grades
  def formatted_grades_for_grading
    Grade.find_by_sql [FORMATTED_GRADES_SQL, { student_id:, lesson_id:, subject_id: subject.id }]
  end

  def perform_grading(skills_descriptors, new_absence)
    Grade.transaction do
      update_absence new_absence
      new_grades = map_new_grades skills_descriptors
      new_grades.each(&:save!)
    end
  end

  def should_grade_update?(grade, skills_descriptors)
    return false if (grade.grade_descriptor_id.nil? || !grade.deleted_at.nil?) && skills_descriptors[grade.skill_id].nil?
    return false if grade.grade_descriptor_id == skills_descriptors[grade.skill_id] && grade.deleted_at.nil?

    true
  end

  def student_absent?
    Absence.find_by(student_id:, lesson_id:).present?
  end

  private

  def update_absence(new_absence)
    Absence.transaction do
      unless student_absent? == new_absence
        if new_absence
          Absence.create(student_id:, lesson:)
        else
          Absence.find_by(student_id:, lesson_id:).destroy!
        end
      end
    end
  end

  def map_new_grades(skills_descriptors)
    formatted_grades_with_deleted.select { |g| should_grade_update?(g, skills_descriptors) }.map do |old_grade|
      descriptor_id = skills_descriptors[old_grade.skill_id]
      if descriptor_id.nil?
        old_grade.deleted_at = Time.zone.now
      elsif old_grade.id.nil?
        old_grade = Grade.new(student:, lesson:, grade_descriptor: GradeDescriptor.find(descriptor_id))
      else
        old_grade.assign_attributes lesson:, student:, deleted_at: nil
        old_grade.grade_descriptor = GradeDescriptor.find descriptor_id
      end
      old_grade
    end
  end

  # Returns Grades with valid grades for graded skills and nulled grades for ungraded skills and with deleted grades
  def formatted_grades_with_deleted
    Grade.find_by_sql [FORMATTED_GRADES_WITH_DELETED_SQL, { student_id:, lesson_id:, subject_id: subject.id }]
  end

  FORMATTED_GRADES_WITH_DELETED_SQL = <<~SQL.squish
    SELECT g.id, student_id, lesson_id, grade_descriptor_id, g.created_at, g.updated_at, g.deleted_at, lesson_uid, s.id as skill_id, mark FROM skills s
      LEFT JOIN grades g ON s.id = g.skill_id AND student_id = :student_id AND lesson_id = :lesson_id
      JOIN assignments a ON s.id = a.skill_id
      WHERE subject_id = :subject_id;
  SQL

  FORMATTED_GRADES_SQL = <<~SQL.squish
    SELECT g.id, student_id, lesson_id, grade_descriptor_id, g.created_at, g.updated_at, g.deleted_at, lesson_uid, s.id as skill_id, mark FROM skills s
      LEFT JOIN grades g ON s.id = g.skill_id AND student_id = :student_id AND lesson_id = :lesson_id AND g.deleted_at IS NULL
      JOIN assignments a ON s.id = a.skill_id
      WHERE subject_id = :subject_id;
  SQL
end
