module ApplicationHelper
  def display_student_group(student)
    student.group_name || 'None'
  end
end
