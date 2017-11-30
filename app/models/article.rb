class Article < ActiveRecord::Base
  has_many :article_entities, inverse_of: :article, dependent: :destroy
  has_many :entities, through: :article_entities, inverse_of: :articles

  validates_presence_of :title
  validates :url, url: true

  def screenshot_path
    Rails.root.join("data", "articles").to_s + "/screenshot-#{id}.jpg"
  end

  def save_screenshot(driver, width = 1024, height = 1024)
    begin
      driver.manage.window.resize_to(width, height)
      driver.navigate.to(url)
      driver.save_screenshot(screenshot_path)
    rescue => e
      return false
    end

    true
  end
end
