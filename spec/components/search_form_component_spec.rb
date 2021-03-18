# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchFormComponent, type: :component do
  it 'renders query parameters as hidden input fields' do
    result = render_inline(SearchFormComponent.new(search: { term: '' }, query_parameters: { foo: 'bar', fooz: 'baz' }))

    expect(result.css('input[type=hidden][name=foo][value=bar]').length).to eq 1
    expect(result.css('input[type=hidden][name=fooz][value=baz]').length).to eq 1
  end

  it 'does not render search, utf8, or page fields' do
    result = render_inline(SearchFormComponent.new(search: { term: '' }, query_parameters: { foo: 'bar', search: 'foo', utf8: 'bar', page: 'baz' }))

    expect(result.css('input[type=hidden][name=foo][value=bar]').length).to eq 1
    expect(result.css('input[type=hidden][name=search]').length).to eq 0
    expect(result.css('input[type=hidden][name=utf8]').length).to eq 0
    expect(result.css('input[type=hidden][name=page]').length).to eq 0
  end

  it 'renders nested query parameters as inputs that will be turned into hash' do
    result = render_inline(SearchFormComponent.new(search: { term: '' }, query_parameters: { foo: 'bar', 'table_order' => { 'key' => 'last_name', 'order' => 'asc' } }))

    expect(result.css('input[type=hidden][name=foo][value=bar]').length).to eq 1
    expect(result.css('input[type=hidden][name=table_order\[key\]][value=last_name]').length).to eq 1
    expect(result.css('input[type=hidden][name=table_order\[order\]][value=asc]').length).to eq 1
  end
end
