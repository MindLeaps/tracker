# frozen_string_literal: true

module Analytics
  class AnalyticsController < ::ApplicationController
    protect_from_forgery with: :exception
    skip_after_action :verify_authorized

    before_action do
      @selected_organization_id = params[:organization_select]
      @selected_chapter_id = params[:chapter_select]
      @selected_group_id = params[:group_select]
      @selected_student_id = params[:student_select]

      @selected_organizations = find_resource_by_id_param @selected_organization_id, Organization
      @selected_chapters = find_resource_by_id_param(@selected_chapter_id, Chapter) { |c| c.where(organization: @selected_organizations) }
      @selected_groups = find_resource_by_id_param(@selected_group_id, Group) { |g| g.where(chapter: @selected_chapters) }
      @selected_students = find_resource_by_id_param(@selected_student_id, Student) { |s| s.where(group: @selected_groups) }
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
  end
end
