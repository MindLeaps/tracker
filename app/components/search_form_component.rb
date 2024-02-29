class SearchFormComponent < ViewComponent::Base
  attr_reader
  def initialize(search:, query_parameters:, autofocus: true)
    @search = search
    @fields = query_parameters.except(:search, :utf8, :page).reduce({}) do |acc, (key, value)|
      if value.is_a?(Hash)
        value.each { |hash_key, hash_value| acc.update({ "#{key}[#{hash_key}]" => hash_value }) }
        acc
      else
        acc.update({ key => value })
      end
    end
    @autofocus = autofocus
  end

  def render?
    !@search.nil?
  end
end
