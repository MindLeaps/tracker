class FormWrapperComponent < ViewComponent::Base
  renders_one :form_content

  erb_template <<~ERB
    <div class="bg-white px-4 py-5 shadow-sm sm:p-4">
      <div class="md:grid md:grid-cols-4 md:gap-6">
        <%= form_content %>
      </div>
    </div>
  ERB
end
