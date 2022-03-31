# frozen_string_literal: true

class CommonComponents::PaginationComponent < ViewComponent::Base
  delegate :pagy_url_for, to: :helpers
  def initialize(pagy:)
    @pagy = pagy
  end

  def previous_url
    return pagy_url_for(@pagy, @pagy.prev) if @pagy.prev

    nil
  end

  def next_url
    return pagy_url_for(@pagy, @pagy.next) if @pagy.next

    nil
  end
end
