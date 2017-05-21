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

  def lesson_student_average_grade(lesson, student)
    return t(:student_absent) if lesson.student_absent? student

    t :student_not_graded
  end

  def student_mini_thumbnail(student)
    return student.profile_image.image.mini_thumb.url if student.profile_image

    'unknown_user.svg'
  end
end
