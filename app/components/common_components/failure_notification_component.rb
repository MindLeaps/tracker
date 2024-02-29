class CommonComponents::FailureNotificationComponent < ViewComponent::Base
  def initialize(notice:)
    @title = notice[:title]
    @text = notice[:text]
  end
end
