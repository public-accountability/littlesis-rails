class Article < ActiveRecord::Base
  has_many :article_entities, inverse_of: :article, dependent: :destroy
  has_many :entities, through: :article_entities, inverse_of: :articles

  validates_presence_of :title
  validates :url, url: true

  def screenshot_path
    Rails.root.join("data", "articles").to_s + "/screenshot-#{id}.jpg"
  end

  def save_screenshot(width = 1024, height = 1024, session = nil)
    session = Capybara::Session.new(:selenium) if session.nil?

    begin
      session.driver.browser.manage.window.resize_to(width, height)
      session.visit(url)
      session.save_screenshot(screenshot_path)
      session.driver.browser.quit
    rescue => e
      binding.pry
      return false
    end

    true
  end
end