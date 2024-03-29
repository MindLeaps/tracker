class CommonComponents::TableNavigationOption < ViewComponent::Base
  with_collection_parameter :option

  def initialize(option:)
    @href = option[:href]
    @name = option[:name]
    @checked = (option[:checked] && 'checked') || ''
    @tooltip = option[:tooltip]
  end
end
