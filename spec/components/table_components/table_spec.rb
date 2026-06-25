require 'rails_helper'

# Minimal stub to test TableComponents::Table in isolation without policy concerns
class StubTableRow < ViewComponent::Base
  with_collection_parameter :item

  def self.columns(**_)
    [{ column_name: 'Name' }]
  end

  def initialize(item:, **_)
    @item = item
    super()
  end

  erb_template '<div class="stub-row"><%= @item %></div>'
end

RSpec.describe TableComponents::Table, type: :component do
  let(:row_component) { StubTableRow }

  context 'when rows is empty' do
    it 'renders the empty message when the empty_message option is provided' do
      render_inline(described_class.new(rows: [], row_component: row_component, options: { empty_message: 'No items found' }))

      expect(page).to have_text('No items found')
    end

    it 'does not render an empty message when no empty_message option is provided' do
      render_inline(described_class.new(rows: [], row_component: row_component))

      expect(page).not_to have_css('[style*="grid-column: 1/-1"]')
    end
  end

  context 'when rows is not empty' do
    it 'does not render the empty message' do
      render_inline(described_class.new(rows: ['Alice'], row_component: row_component, options: { empty_message: 'No items found' }))

      expect(page).not_to have_text('No items found')
      expect(page).to have_css('.stub-row', text: 'Alice')
    end
  end
end
