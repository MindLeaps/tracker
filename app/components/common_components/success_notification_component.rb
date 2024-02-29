class CommonComponents::SuccessNotificationComponent < ViewComponent::Base
  def initialize(notice:)
    @title = notice[:title]
    @text = notice[:text]
    @link_path = notice[:link_path]
    @link_text = notice[:link_text]
    @button_path = notice[:button_path]
    @button_text = notice[:button_text]
    @button_method = notice[:button_method]
  end

  def link?
    @link_path.present? && @link_text.present?
  end

  def button?
    @button_path.present? && @button_method.present? && @button_text.present?
  end
end
