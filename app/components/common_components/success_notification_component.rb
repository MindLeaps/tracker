# frozen_string_literal: true

class CommonComponents::SuccessNotificationComponent < ViewComponent::Base
  def initialize(notice:)
    @title = notice[:title]
    @text = notice[:text]
    @link_path = notice[:link_path]
    @link_text = notice[:link_text]
  end

  def link?
    @link_path.present? && @link_text.present?
  end
end
