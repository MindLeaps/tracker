class Datepicker < ViewComponent::Base
  renders_one :input_field

  erb_template <<~ERB
    <div class="inline-block" data-controller="datepicker" data-datepicker-date-value=<%= @date %> data-datepicker-id-value=<%= @field_id %>>
      <%= input_field %>
    </div/>
  ERB

  def initialize(date:, field_id:)
    @date = date
    @field_id = field_id
  end
end
