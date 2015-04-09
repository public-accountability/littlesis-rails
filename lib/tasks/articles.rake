namespace :articles do
  desc "creates square versions of images"
  task save_screenshots: :environment do
    if list_id = ENV['LIST_ID']
      entity_ids = List.find(list_id).entities_with_couples.pluck(:id)
      articles = Article.joins(:article_entities).where(article_entities: { entity_id: entity_ids })
    else
      articles = Article.all
    end

    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.add_extension('data/selenium/adblock_plus-2.6.9-an+sm+tb+fx.xpi')
    driver = Selenium::WebDriver.for(:firefox, profile: profile)

    # session = Capybara::Session.new(:selenium)
    # binding.pry

    articles.each_with_index do |a, i|
      next if File.exist?(a.screenshot_path)
      if a.save_screenshot(driver, 768, 768)
        print "[#{i}/#{articles.count}] saved #{a.url}\n"
      end
    end    
  end
end