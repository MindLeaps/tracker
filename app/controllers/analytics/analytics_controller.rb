module Analytics
  class AnalyticsController < ::HtmlController
    protect_from_forgery with: :exception
    skip_after_action :verify_authorized

    before_action do
      @available_organizations = policy_scope Organization.where(deleted_at: nil).order(:organization_name)
      @available_chapters = policy_scope Chapter.where(deleted_at: nil).order(:chapter_name)
      @available_groups = policy_scope Group.where(deleted_at: nil).order(:group_name)
      @available_students = policy_scope Student.where(deleted_at: nil).order(:last_name, :first_name)
      @available_subjects = policy_scope Subject.where(deleted_at: nil)

      @selected_organization_id = params[:organization_id] || @available_organizations.first.id
      @selected_chapter_id = params[:chapter_id]
      @subject = params[:subject_id] || @available_subjects.first&.id
      @selected_group_id = params[:group_id]
      @selected_student_id = params[:student_id]
    end

    def find_resource_by_id_param(id, resource_class)
      return resource_class.where(id:) unless all_selected?(id)
      return policy_scope(yield resource_class) if block_given?

      policy_scope resource_class
    end

    def all_selected?(id_selected)
      id_selected.nil? || id_selected == '' || id_selected == 'All'
    end

    def colors
      %w[#e6194B #3cb44b #ffe119 #4363d8 #f58231 #911eb4 #42d4f4 #f032e6 #bfef45 #fabed4 #469990 #dcbeff #9A6324 #fffac8 #800000 #aaffc3 #808000 #ffd8b1 #000075 #a9a9a9 #ffffff #000000]
    end

    def get_color(index)
      colors[index % colors.length]
    end

    def selected_param_present_but_not_all?(selected_param)
      selected_param.present? && (selected_param != 'All')
    end
  end
end
