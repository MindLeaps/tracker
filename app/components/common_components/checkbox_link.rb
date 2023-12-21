# frozen_string_literal: true

class CommonComponents::CheckboxLink < ViewComponent::Base
  include ApplicationHelper
  erb_template <<~ERB
    <%= link_to @href do %>
      <label class="cursor-pointer text-sm text-gray-600">
      <input type="checkbox" <%= @checked ? 'checked' : '' %> class="cursor-pointer" /> <%= t(:show_deleted) %>
      </label>
    <% end %>
  ERB
  def initialize(checked:, label:, href:)
    @checked = checked
    @label = label
    @href = href
  end
end
