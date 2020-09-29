require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.headless!
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--window-size=1280,1920')
  options.add_argument('--no-sandbox')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.register_driver :headless_firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.headless!
  Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
end

Capybara.ignore_hidden_elements = false
Capybara.javascript_driver = :headless_chrome
Capybara.server = :puma, { Silent: true }  # Remove crummy test output
Capybara.default_max_wait_time = ENV["CI"] ? 15 : 5
Capybara.default_host = "#{Lilsis::Application.default_url_options[:protocol]}://#{Lilsis::Application.default_url_options[:host]}"
