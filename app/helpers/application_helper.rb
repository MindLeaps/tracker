module ApplicationHelper
  def student_group_name(student)
    student.group_name || 'None'
  end

  def student_name(student)
    [student.last_name, student.first_name].join(', ')
  end
end
