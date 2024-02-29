module Helpers
  # Poltergeist does not want to click overlapping elements, including our fancy checkbox, so we need to use .trigger there to force it
  # Other drivers, like chrome, do not support trigger method
  def click_link_compat(locator)
    if Capybara.current_driver == :poltergeist || Capybara.current_driver == :poltergeist_debug
      find(:link, locator).trigger('click')
    else
      click_link locator
    end
  end
end
