module ApplicationHelper
  def student_group_name(student)
    student.group_name || 'None'
  end
end
