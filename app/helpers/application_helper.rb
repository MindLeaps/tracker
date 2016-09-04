module ApplicationHelper
  def student_group_name(student)
    student.group_name || 'None'
  end

  def group_chapter_name(group)
    group.chapter_name || 'None'
  end

  def chapter_organization_name(chapter)
    chapter.organization_name || 'None'
  end

  def chapter_students_number(chapter)
    chapter.groups.reduce(0) { |a, e| a + e.students.length }
  end

  def user_image(size = 40)
    "#{current_user.image}?sz=#{size}"
  end
end
