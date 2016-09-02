module ApplicationHelper
  def student_group_name(student)
    student.group_name || 'None'
  end

  def group_chapter_name(group)
    group.chapter_name || 'None'
  end
end
