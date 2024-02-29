class ValidationErrorComponent < ViewComponent::Base
  erb_template <<~ERB
    <% @errors.each do |e| %>
      <p class="validation-error"><%= e.full_message %></p>
    <% end %>
  ERB

  def initialize(model:, key:)
    @errors = model.errors.where(key)
  end

  def render?
    @errors.size.positive?
  end
end
