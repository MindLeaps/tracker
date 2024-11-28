# Capybara calls methods that Selenium has deprecated and our output gets full of deprecation messages
# This just silents the deprecations until capybara makes the change to stop calling deprecated methods
Selenium::WebDriver.logger.ignore(:clear_local_storage, :clear_session_storage)
