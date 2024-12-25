class Datepicker < ViewComponent::Base
  erb_template <<~ERB
    <div class="date-picker-container inline-block" data-controller="datepicker" data-datepicker-date-value=<%= @date %>>
      <input id="datepicker" class="<%= @custom_class %>">
    </div/>
  ERB

  def initialize(date:, custom_class:)
    @date = date
    @custom_class = custom_class
  end
end