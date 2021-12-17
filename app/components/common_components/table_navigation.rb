# frozen_string_literal: true

class CommonComponents::TableNavigation < ViewComponent::Base
  def initialize(pagy:, resource:, span:, search: nil, options: [])
    @resource = resource
    @options = options
    @search = search
    @pagy = pagy
    @span = span
  end

  def search_component
    SearchFormComponent.new(search: @search, query_parameters: request.query_parameters)
  end
end
