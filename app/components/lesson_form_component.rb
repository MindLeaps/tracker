class LessonFormComponent < ViewComponent::Base
  class ChapterGroups
    attr_reader :groups, :chapter_display

    def initialize(chapter, permitted_groups)
      @groups = permitted_groups.filter { |g| g.chapter_id == chapter.id }.sort_by(&:chapter_group_name_with_full_mlid)
      @chapter_display = "#{chapter.organization_name} - #{chapter.chapter_name} (#{chapter.full_mlid})"
    end
  end

  class OrganizationSubjects
    attr_reader :subjects, :org_display

    def initialize(organization, current_user)
      @subjects = SubjectPolicy::Scope.new(current_user, organization.subjects).resolve
      @org_display = "#{organization.organization_name} - #{organization.mlid}"
    end
  end
  erb_template <<~ERB
    <%= form_with model: @lesson, class: 'space-y-0.5' do |f| %>
      <div class="bg-white px-4 py-5 shadow-sm sm:p-4">
        <div class="md:grid md:grid-cols-4 md:gap-6">
          <div class="md:col-span-1">
            <h3 class="text-lg font-medium leading-6 text-gray-900"><%= t(:lesson_information) %></h3>
          </div>
          <div class="mt-5 md:col-span-3 md:mt-0">
            <div class="grid grid-cols-6 gap-4">
              <div class="col-span-6 lg:col-span-2">
                <%= f.label :group, class: 'block text-sm font-medium text-gray-700' %>
                <%= f.grouped_collection_select :group_id, @chapter_groups, :groups, :chapter_display, :id, :chapter_group_name_with_full_mlid, { include_blank: true }, disabled: @action == :update,
                 class: 'mt-1 block w-full rounded-md border-purple-500 shadow-xs focus:border-green-600 focus:ring-green-600 sm:text-sm disabled:bg-gray-200 disabled:text-gray-400 disabled:border-gray-100' %>
                <%= render ValidationErrorComponent.new(model: @lesson, key: :group) %>
              </div>
              <div class="col-span-6 lg:col-span-2">
                <%= f.label :subject, class: 'block text-sm font-medium text-gray-700' %>
                <%= f.grouped_collection_select :subject_id, @org_subjects, :subjects, :org_display, :id, :subject_name, { include_blank: true }, disabled: @action == :update,
                 class: 'mt-1 block w-full rounded-md border-purple-500 shadow-xs focus:border-green-600 focus:ring-green-600 sm:text-sm disabled:bg-gray-200 disabled:text-gray-400 disabled:border-gray-100' %>
                <%= render ValidationErrorComponent.new(model: @lesson, key: :subject) %>
              </div>
              <div class="col-span-6 lg:col-span-2"></div>
              <div class="col-span-6 lg:col-span-2">
                <%= f.label :date, class: 'block text-sm font-medium text-gray-700' %>
                <%= render Datepicker.new(date: @lesson.date, target: 'date', form: f, prepopulate: true) %>
                <%= render ValidationErrorComponent.new(model: @lesson, key: :date) %>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="bg-white px-4 py-5 shadow-sm sm:p-4">
        <div class="md:grid md:grid-cols-4 md:gap-6">
          <div class="md:col-span-1"></div>
          <div class="mt-5 md:col-span-3 md:mt-0">
            <div class="grid grid-cols-6 gap-4">
              <div class="col-span-6 lg:col-span-4">
                <%= f.submit class: 'px-4 py-2 border border-transparent shadow-xs text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-hidden focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 cursor-pointer' %>
              </div>
            </div>
          </div>
        </div>
      </div>
    <% end %>

  ERB
  def initialize(lesson:, action:, current_user:)
    @lesson = lesson
    @action = action
    permitted_groups = GroupPolicy::Scope.new(current_user, Group.includes(chapter: :organization)).resolve
    @chapter_groups = structure_groups(permitted_groups).sort_by(&:chapter_display)
    @org_subjects = OrganizationPolicy::Scope.new(current_user, Organization.includes(:subjects)).resolve
                                             .filter { |o| o.subjects.size.positive? }
                                             .map { |o| OrganizationSubjects.new(o, current_user) }
  end

  def structure_groups(permitted_groups)
    permitted_groups.map(&:chapter).uniq.map do |chapter|
      ChapterGroups.new(chapter, permitted_groups)
    end
  end
end
