class CommonComponents::MultiselectComponent < ViewComponent::Base
  erb_template <<~ERB
    <div data-controller="multiselect" data-multiselect-label-value="<%= @label %>" data-multiselect-select-name-value="<%= @target %>" class="col-span-6 lg:col-span-2 relative">
      <!-- Hidden inputs for each selected item from the menu-->
      <div data-multiselect-target="hiddenField">
        <% @selected_values&.each do |value| %>
          <input type="hidden" name="<%= @target %>" value="<%= value %>">
        <% end %>
      </div>
      <button type="button" data-action="click->multiselect#toggleMenu"
        class="w-full border border-purple-500 p-2 rounded-md bg-white flex justify-between items-center text-md sm:text-sm font-medium focus:border-green-600 focus:ring-green-600">
        <span data-multiselect-target="label" > <%= @label %> </span>
        <%= helpers.inline_svg_tag("arrow_down.svg", class: "w-5 h-5 fill-gray-500") %>
      </button>
      <!-- Dropdown Menu -->
      <div class="absolute p-1 w-full border rounded-md bg-white hidden z-10" data-multiselect-target="menu">
        <% @options.each do |option| %>
          <div class="hover:bg-gray-100 cursor-pointer flex justify-between p-2 rounded-md flex justify-between items-center text-md sm:text-sm font-medium"
               data-value="<%= option[:id] %>"
               data-depend-id="<%= option[:depend_id] %>"
               data-action="click->multiselect#toggleOption"
               data-multiselect-target="option">
            <span><%= option[:label] %></span>
            <%= helpers.inline_svg_tag("checkmark.svg", class: "w-4 h-4 text-green-600 checkmark hidden") %>
          </div>
        <% end %>
      </div>
    </div>
  ERB

  def initialize(label:, target:, options:, selected_values: nil)
    @label = label
    @target = target
    @options = options
    @selected_values = selected_values
  end
end
