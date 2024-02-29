def seed_group_random_grades(group, subject)
  current_date = 6.months.ago

  60.times do
    # rubocop:disable Rails/Output
    puts("Lesson: #{current_date} - Chapter: #{group.chapter.chapter_name} - Group: #{group.group_name}")
    # rubocop:enable Rails/Output
    lesson = Lesson.create(subject:, date: current_date, group:)

    group.students.each do |student|
      seed_student_performance student, lesson
    end

    current_date += 1.day
  end
end

def seed_student_performance(student, lesson)
  return mark_absent(student, lesson) if rand < 0.1

  seed_student_grades student, lesson
end

def mark_absent(student, lesson)
  lesson.mark_student_as_absent student
end

def seed_student_grades(student, lesson)
  Grade.transaction do
    lesson.subject.skills.each do |skill|
      Grade.create lesson:, student:, grade_descriptor: skill.grade_descriptors.sample
    end
  end
end
