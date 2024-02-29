class CommonComponents::PaginationComponent < ViewComponent::Base
  delegate :pagy_url_for, to: :helpers
  def initialize(pagy:)
    @pagy = pagy
  end

  def first_url
    return pagy_url_for(@pagy, 1) if @pagy.prev

    nil
  end

  def previous_url
    return pagy_url_for(@pagy, @pagy.prev) if @pagy.prev

    nil
  end

  def next_url
    return pagy_url_for(@pagy, @pagy.next) if @pagy.next

    nil
  end

  def last_url
    return pagy_url_for(@pagy, @pagy.last) if @pagy.next

    nil
  end
end
