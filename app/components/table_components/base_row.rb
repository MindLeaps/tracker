# frozen_string_literal: true

class TableComponents::BaseRow < ViewComponent::Base
  with_collection_parameter :item

  def initialize(item:, item_counter:, pagy:)
    @item = item
    @item_counter = item_counter
    @pagy = pagy
  end

  def shaded?
    @item_counter.odd?
  end

  def can_update?
    helpers.policy(@item).update?
  end
end
