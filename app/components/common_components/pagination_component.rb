class CommonComponents::PaginationComponent < ViewComponent::Base

  def initialize(pagy:)
    @pagy = pagy
  end

  def first_url
    return @pagy.page_url(1) if @pagy.previous

    nil
  end

  def previous_url
    return @pagy.page_url(@pagy.previous) if @pagy.previous

    nil
  end

  def next_url
    return @pagy.page_url(@pagy.next) if @pagy.next

    nil
  end

  def last_url
    return @pagy.page_url(@pagy.last) if @pagy.next

    nil
  end
end
