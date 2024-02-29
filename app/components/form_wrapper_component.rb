class FormWrapperComponent < ViewComponent::Base
  renders_one :form_content

  erb_template <<~ERB
    <%= form_with model: @model, class: 'space-y-0.5' do |f| %>
      <div class="bg-white px-4 py-5 shadow sm:p-4">
        <div class="md:grid md:grid-cols-4 md:gap-6">
          <%= form_content %>
        </div>
      </div>
    <% end %>
  ERB
end
