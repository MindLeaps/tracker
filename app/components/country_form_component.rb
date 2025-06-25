class CountryFormComponent < ViewComponent::Base
  erb_template <<~ERB
    <%= form_with model: @country, class: 'space-y-0.5' do |f| %>
      <div class="bg-white px-4 py-5 shadow sm:p-4">
        <div class="md:grid md:grid-cols-4 md:gap-6">
          <div class="md:col-span-1">
            <h3 class="text-lg font-medium leading-6 text-gray-900"><%= t(:country_information) %></h3>
          </div>
          <div class="mt-5 md:col-span-3 md:mt-0">
            <div class="grid grid-cols-6 gap-4">
              <div class="col-span-6 lg:col-span-2">
                <%= f.label :country_name, class: 'field-label' %>
                <%= f.text_field :country_name, autofocus: true, class: 'mt-1 block w-full rounded-md border-purple-500 shadow-sm focus:border-green-600 focus:ring-green-600 sm:text-sm' %>
                <%= render ValidationErrorComponent.new(model: @country, key: :country_name) %>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="bg-white px-4 py-5 shadow sm:p-4">
        <div class="md:grid md:grid-cols-4 md:gap-6">
          <div class="md:col-span-1"></div>
          <div class="mt-5 md:col-span-3 md:mt-0">
            <div class="grid grid-cols-6 gap-4">
              <div class="col-span-6 lg:col-span-4">
                <%= f.submit class: 'px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 cursor-pointer' %>
                <% if @cancel %>
                  <%= link_to t(:cancel), nil, class: 'dangerous-button', data: { action: 'click->transition#close' } %>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
    <% end %>
  ERB

  def initialize(country:, action:, cancel: false)
    @country = country
    @action = action
    @cancel = cancel
  end
end
