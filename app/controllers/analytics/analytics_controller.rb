module Analytics
  class AnalyticsController < ::HtmlController
    protect_from_forgery with: :exception
    skip_after_action :verify_authorized

    before_action do
      @available_organizations = policy_scope Organization.where(deleted_at: nil).order(:organization_name)
      @available_chapters = policy_scope Chapter.where(deleted_at: nil).order(:chapter_name)
      @available_groups = policy_scope Group.where(deleted_at: nil).order(:group_name)
      @available_subjects = policy_scope Subject.where(deleted_at: nil)
      @available_students = []

      @selected_organization_id = params[:organization_id].presence || @available_organizations.first&.id
      @selected_chapter_id = params[:chapter_id]
      @subject = params[:subject_id] || @available_subjects.first&.id
      @selected_group_ids = params[:group_ids]
      @selected_student_id = params[:student_id]
      @selected_student_ids = selected_student_ids

      @from = params[:from_date] || default_from_date
      @to = params[:to_date] || Date.current
    end

    def default_from_date
      organization = policy_scope(Organization).find_by(id: @selected_organization_id)
      return Date.new(Date.current.year, 1, 1) unless organization

      last_lesson_date = Lesson.joins(:grades)
                               .where(grades: { student_id: organization.students.select(:id) })
                               .order(date: :desc)
                               .pick(:date)

      last_lesson_date&.beginning_of_month || Date.new(Date.current.year, 1, 1)
    end

    def find_resource_by_id_param(id, resource_class)
      scoped_resources = policy_scope(resource_class)
      scoped_resources = yield scoped_resources if block_given?

      return scoped_resources if all_selected?(id)

      scoped_resources.where(id:)
    end

    def all_selected?(id_selected)
      id_selected.nil? || id_selected == '' || id_selected == t(:all)
    end

    def colors
      %w[#7cb5ec #434348 #90ed7d #f7a35c #8085e9 #f15c80 #e4d354 #2b908f #f45b5b #91e8e1]
    end

    def get_color(index)
      colors[index % colors.length]
    end

    def selected_param_present_but_not_all?(selected_param)
      selected_param.present? && (selected_param != t(:all))
    end

    def selected_student_ids
      ids = normalized_ids(params[:student_ids].presence || params[:student_id])
      ids.reject { |id| all_selected?(id) }
    end

    def normalized_ids(value)
      return [] if value.blank?

      value.is_a?(Array) ? value : [value]
    end
  end
end
