class ValidationErrorComponent < ViewComponent::Base
  erb_template <<~ERB
    <% @errors.each do |e| %>
      <p class="validation-error"><%= @remove_prepend ? e.message : e.full_message %></p>
    <% end %>
  ERB

  def initialize(model:, key:, remove_prepend: false)
    @errors = model.errors.where(key)
    @remove_prepend = remove_prepend
  end

  def render?
    @errors.size.positive?
  end
end
