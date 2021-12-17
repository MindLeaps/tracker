# frozen_string_literal: true

class SearchFormComponent < ViewComponent::Base
  attr_reader
  def initialize(search:, query_parameters:)
    @search = search
    @fields = query_parameters.except(:search, :utf8, :page).reduce({}) do |acc, (key, value)|
      if value.is_a?(Hash)
        value.each { |hash_key, hash_value| acc.update({ "#{key}[#{hash_key}]" => hash_value }) }
        acc
      else
        acc.update({ key => value })
      end
    end
  end

  def render?
    !@search.nil?
  end
end
