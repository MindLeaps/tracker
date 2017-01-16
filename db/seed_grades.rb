# frozen_string_literal: true
# rubocop:disable Style/IndentArray
def seed_student_grades(student, lesson)
  lesson.subject.skills.each do |skill|
    student.grades.create([
      { lesson: lesson, student: student, grade_descriptor: skill.grade_descriptors.sample }
    ])
  end
end

def seed_group_grades(group, subject)
  current_date = 6.months.ago

  60.times do
    lesson = Lesson.create subject: subject, date: current_date, group: group

    group.students.each do |student|
      seed_student_grades student, lesson
    end

    current_date += 1.day
  end
end
