# frozen_string_literal: true

# Takes screenshots of oligrapher using firefox and Selenium Webdriver
# It requires Geckodriver > 0.15
# Download geckodriver here: https://github.com/mozilla/geckodriver/releases
# and put it anywhere that's accessible from the shell's path
class Screenshot
  FIREFOX_CAPABILITIES = Selenium::WebDriver::Remote::Capabilities.firefox(accept_insecure_certs: true)

  def self.take(url, path)
    status = true
    Selenium::WebDriver::Firefox::Binary.path = '/usr/bin/firefox'

    Headless.ly do
      driver = Selenium::WebDriver.for :firefox, desired_capabilities: FIREFOX_CAPABILITIES
      driver.manage.window.size = Selenium::WebDriver::Dimension.new(960, 550)
      driver.get url
      # hide annotations
      driver.execute_script("document.getElementById('oligrapherGraphAnnotation') ? (document.getElementById('oligrapherGraphAnnotation').style.display = 'none') : null;")
      # hide zoom buttons
      driver.execute_script "document.getElementById('zoomButtons').style.display = 'none'"
      driver.save_screenshot(path)
    rescue => e
      Rails.logger.info "Failed to capture screenshot for #{url}: #{e.message}"
      Rails.logger.debug e.backtrace
      status = false
    ensure
      driver&.quit
    end
    return status
  end

  def self.resize_map_thumbnail(path)
    `mogrify -crop 960x550+60+40 #{path}`
  end
end
