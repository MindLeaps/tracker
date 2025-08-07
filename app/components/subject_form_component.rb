class SubjectFormComponent < ViewComponent::Base
  include Turbo::FramesHelper

  erb_template <<~ERB
    <%= form_with model: @subject, class: 'space-y-0.5' do |f| %>
      <%= render FormWrapperComponent.new do |fw| %>
        <% fw.with_form_content do %>
          <div class="md:col-span-1">
            <h3 class="text-lg font-medium leading-6 text-gray-900"><%= t(:subject_information) %></h3>
          </div>
          <div class="mt-5 md:col-span-3 md:mt-0">
            <div class="grid grid-cols-6 gap-4">
              <div class="col-span-6 lg:col-span-2">
                <%= f.label :subject_name, class: 'block text-sm font-medium text-gray-700' %>
                <%= f.text_field :subject_name, autofocus: true, class: 'mt-1 block w-full rounded-md border-purple-500 shadow-sm focus:border-green-600 focus:ring-green-600 sm:text-sm' %>
              </div>
              <div class="col-span-6 lg:col-span-2">
                <%= f.label :organization_id, class: 'block text-sm font-medium text-gray-700' %>
                <%= f.collection_select :organization_id, @permitted_organizations, :id, :organization_name, {}, class: 'mt-1 block w-full rounded-md border-purple-500 shadow-sm focus:border-green-600 focus:ring-green-600 sm:text-sm' %>
              </div>
            </div>
          </div>
          <div class="md:col-span-1">
            <h3 class="text-lg font-medium leading-6 text-gray-900"><%= t(:skills) %></h3>
          </div>
          <div class="mt-5 md:col-span-3 md:mt-0">
            <%= turbo_frame_tag f.field_id(:assignments) do %>
              <div id="skills" class="grid grid-cols-6 gap-4" data-controller="association">
                <%= f.fields_for :assignments, include_id: false do |sf| %>
                  <% id = SecureRandom.uuid %>
                  <div class="grid grid-cols-6 col-span-6 gap-4 <%= if sf.object.marked_for_destruction? then 'hidden' else '' end %>" data-association-target="removable" id="<%= id %>">
                    <div class="col-span-2">
                      <%= sf.hidden_field :id %>
                      <%= sf.label :skill_id, class: 'block text-sm font-medium text-gray-700' %>
                      <%= sf.collection_select :skill_id, @permitted_skills, :id, :skill_name, {}, class: 'mt-1 block w-full rounded-md border-purple-500 shadow-sm focus:border-green-600 focus:ring-green-600 sm:text-sm' %>
                    </div>
                    <%= sf.check_box :_destroy, class: 'hidden', 'data-association-target': 'checkable', 'data-association-id': id %>
                    <div class="col-span-2 relative">
                      <button class="dangerous-button absolute bottom-0 cursor-pointer" data-action="association#remove" data-association-remove-id-param="<%= id %>"><%= t(:delete_skill) %></button>
                    </div>
                  </div>
                <% end %>
              </div>
              <%= f.submit t(:add_skill), class: 'normal-button mt-4', name: :add_skill, data: { turbo_frame: f.field_id(:assignments) } %>
            <% end %>
          </div>
          <div class="md:col-span-1"></div>
          <div class="mt-5 md:col-span-3 md:mt-0">
            <%= f.submit class: 'normal-button' %>
          </div>
        <% end %>
      <% end %>
    <% end %>
  ERB

  def initialize(subject:, action:, current_user:)
    @subject = subject
    @action = action
    @permitted_organizations = OrganizationPolicy::Scope.new(current_user, Organization).resolve.order(organization_name: :asc)
    @permitted_skills = SkillPolicy::Scope.new(current_user, Skill.where(deleted_at: nil)).resolve.order(created_at: :asc)
  end
end
