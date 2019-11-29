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
    return current_scopes[:table_order][:order] if current_scopes.dig(:table_order, :key).to_s == order_key.to_s

    nil
  end

  def order_parameters(order_key, custom_scope_order = false)
    request.query_parameters.merge(table_order: { key: order_key, order: order_for(order_key).to_s == 'asc' ? :desc : :asc, custom_scope_order: custom_scope_order })
  end

  def order_icon(order_key)
    order = order_for order_key
    return 'sortable.svg' unless order

    order == 'desc' ? 'arrow_down.svg' : 'arrow_up.svg'
  end

  def excluding_deleted?
    current_scopes[:exclude_deleted]
  end

  def show_deleted_url
    request.query_parameters.merge(excluding_deleted? ? { exclude_deleted: false } : { exclude_deleted: nil })
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
    user.name || t(:name_unknown)
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

  def general_analytics?
    current_page?(general_analytics_url) || current_page?(root_url) || request.fullpath == general_analytics_path
  end

  def subject_analytics?
    current_page?(subject_analytics_url) || request.fullpath == subject_analytics_path
  end

  def group_analytics?
    current_page?(group_analytics_url) || request.fullpath == group_analytics_path
  end

  def link_to_disable_if_current(url)
    return '' if current_page? url

    "href=#{url}"
  end

  def href_to(url)
    "href=#{url}"
  end
end
