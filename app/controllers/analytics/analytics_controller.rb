# frozen_string_literal: true

module Analytics
  class AnalyticsController < ::HtmlController
    protect_from_forgery with: :exception
    skip_after_action :verify_authorized

    before_action do
      @available_organizations = policy_scope Organization
      @available_chapters = policy_scope Chapter
      @available_groups = policy_scope Group
      @available_students = policy_scope Student
      @available_subjects = policy_scope Subject

      @selected_organization_id = @available_organizations.first.id unless params[:organization_select]
      @selected_chapter_id = params[:chapter_select]
      @subject = @available_subjects.first.id unless params[:subject_select]
      @selected_group_id = params[:group_select]
      @selected_student_id = params[:student_select]
    end

    def find_resource_by_id_param(id, resource_class)
      return resource_class.where(id: id) unless all_selected?(id)
      return policy_scope(yield resource_class) if block_given?

      policy_scope resource_class
    end

    def all_selected?(id_selected)
      id_selected.nil? || id_selected == '' || id_selected == 'All'
    end

    def colors
      %w[#7cb5ec #434348 #90ed7d #f7a35c #8085e9 #f15c80 #e4d354 #2b908f #f45b5b #91e8e1]
    end

    def get_color(index)
      colors[index % colors.length]
    end

    def selected_param_present_but_not_all?(selected_param)
      selected_param.present? && (selected_param != 'All')
    end
  end
end
