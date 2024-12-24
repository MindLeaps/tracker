class CommonComponents::Datepicker < ViewComponent::Base
  ERBerb_template <<~ERB
    <div class="date-picker-container">
      <input id="datepicker" data-controller="datepicker">
    </div/>
  ERB

  def initialize(*)
    super
  end
end

