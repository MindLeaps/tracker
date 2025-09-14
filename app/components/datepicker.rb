class Datepicker < ViewComponent::Base
  renders_one :input_field

  erb_template <<~ERB
    <div class="inline-block" data-controller="datepicker" data-datepicker-date-value=<%= @date %> >
      <% if @form %>
        <%= @form.text_field @target, data: { 'datepicker-target' => 'picker' },
         class: 'mt-1 rounded-md border-purple-500 text-sm focus:border-green-600 focus:outline-hidden focus:ring-green-600', autocomplete: 'disabled' %>
      <% elsif @custom_name %>
        <%= text_field_tag @custom_name, @date, data: { 'datepicker-target' => 'picker' },
         class: 'mt-1 rounded-md border-purple-500 text-sm focus:border-green-600 focus:outline-hidden focus:ring-green-600', autocomplete: 'disabled' %>
      <% else %>
        <%= input_field %>
      <% end %>
    </div>
  ERB

  def initialize(date:, target:, form: nil, custom_name: nil)
    @date = date
    @target = target
    @form = form
    @custom_name = custom_name
  end
end
