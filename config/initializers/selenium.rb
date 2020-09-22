# frozen_string_literal: true

firefox_path = APP_CONFIG['firefox_path'] || '/usr/bin/firefox'

if File.exist?(firefox_path)
  Selenium::WebDriver::Firefox::Binary.path = firefox_path
else
  Rails.logger.warn "Firefox path #{firefox_path} does not exist"
end

unless Rails.env.production?
  Selenium::WebDriver.logger.level = :debug
end
