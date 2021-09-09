# frozen_string_literal: true

# Wrapper around selenium-controlled firefox
# It requires Geckodriver (https://github.com/mozilla/geckodriver)
#
# Firefox.visit('https://littlesis.org') do |driver|
#   # use driver
# end
#
class Firefox
  SELENIUM_OPTIONS = Selenium::WebDriver::Firefox::Options.new.tap do |options|
    options.headless!
  end.freeze

  DIMENSIONS = [1920, 1080].freeze # [width, height]

  def self.visit(url)
    driver = new_driver
    driver.get url
    yield driver
  ensure
    driver&.quit
  end

  def self.new_driver
    Selenium::WebDriver.for(:firefox, capabilities: SELENIUM_OPTIONS).tap do |driver|
      driver.manage.window.size = Selenium::WebDriver::Dimension.new(*DIMENSIONS)
    end
  end
end
