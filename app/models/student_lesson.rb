class StudentLesson < ApplicationRecord
  belongs_to :student
  belongs_to :lesson
  has_one :subject, through: :lesson
  has_many :skills, through: :subject

  def grades
    Grade.find_by_sql [GRADES_SQL, {student_id: student_id, lesson_id: lesson_id, subject_id: subject.id}]
  end

  GRADES_SQL = <<~SQL
    SELECT g.* FROM skills s LEFT JOIN grades g ON s.id = g.skill_id AND student_id = :student_id AND lesson_id = :lesson_id
      JOIN assignments a ON s.id = a.skill_id
      WHERE subject_id = :subject_id;
  SQL
end
