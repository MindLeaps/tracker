# frozen_string_literal: true
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
    chapter.groups.reduce(0) { |acc, elem| acc + elem.students.length }
  end

  def user_image(user, size = 40)
    return "#{user.image}?sz=#{size}" if user.image
    image_url 'unknown_user.svg'
  end

  def current_user_image
    user_image current_user
  end

  def user_name(user)
    user.name || 'Inactive User'
  end
end
