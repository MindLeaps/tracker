class CommonComponents::CheckboxLink < ViewComponent::Base
  include ApplicationHelper

  erb_template <<~ERB
    <%= link_to @href do %>
      <label class="cursor-pointer text-sm text-gray-600">
      <input type="checkbox" <%= @checked ? 'checked' : '' %> class="h-4 w-4 ml-4 border-purple-500 text-green-600 focus:ring-green-600 cursor-pointer" /> <%= t(:show_deleted) %>
      </label>
    <% end %>
  ERB
  def initialize(checked:, label:, href:)
    @checked = checked
    @label = label
    @href = href
  end
end
