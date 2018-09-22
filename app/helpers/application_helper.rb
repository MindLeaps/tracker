# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def student_group_name(student)
    student.group_name || 'None'
  end

  def group_chapter_name(group)
    group.chapter_name || 'None'
  end

  def group_summary_chapter_organization_name(group)
    "#{group.chapter_name} - #{group.organization_name}"
  end

  def order_for(order_key)
    current_scopes.dig :order, order_key
  end

  def order_parameters(order_key)
    { order: { order_key => order_for(order_key) == 'asc' ? :desc : :asc } }
  end

  def custom_order_parameter(order_key)
    { order_key => current_scopes.dig(order_key) == 'asc' ? :desc : :asc }
  end

  def order_icon(order_key)
    order = order_for order_key
    return 'sortable.svg' unless order

    order == 'desc' ? 'arrow_down.svg' : 'arrow_up.svg'
  end

  def chapter_organization_name(chapter)
    chapter.organization_name || 'None'
  end

  def chapter_students_number(chapter)
    chapter.groups.reduce(0) { |acc, elem| acc + elem.students.exclude_deleted.length }
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

  def name_or_email(user)
    user.name || user.email
  end

  def lesson_student_average_grade(lesson, student)
    return t(:student_absent) if lesson.student_absent? student

    t :student_not_graded
  end

  def student_mini_thumbnail(student)
    return student.profile_image.image.mini_thumb.url if student.profile_image

    'unknown_user.svg'
  end

  def user_role_in(user, organization)
    user.role_in(organization).try(:symbol)
  end

  def user_global_role(user)
    user.global_role.try(:symbol)
  end
end
