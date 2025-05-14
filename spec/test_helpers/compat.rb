module Helpers
  # Poltergeist does not want to click overlapping elements, including our fancy checkbox, so we need to use .trigger there to force it
  # Other drivers, like chrome, do not support trigger method
  def click_link_compat(locator)
    if [:poltergeist, :poltergeist_debug].include?(Capybara.current_driver)
      find(:link, locator).trigger('click')
    else
      click_link locator
    end
  end
end
