source 'https://rubygems.org'

gem 'rails', '5.2.0'
gem 'mysql2', '~> 0.4.10'

# Rack middleware
gem 'rack-rewrite', '~> 1.5.1'

# users and authentication
gem 'devise', '~> 4.4.3'

# Versioning
gem 'paper_trail', '9.1.1'

# delayed job
gem 'daemons' # Required by delayed_job
gem 'delayed_job', '~> 4.1.5'
gem 'delayed_job_active_record', '>= 4.1.3'

# Assets, image uploading & processing
gem 'aws-sdk-cloudfront', '~> 1'
gem 'aws-sdk-s3', '~> 1'
# gem 'carrierwave'
gem 'mini_magick'
gem 'rmagick'

gem 'sprockets', '~> 3.0'
gem 'asset_sync', '~> 2.4.0'
gem "fog-aws"

gem 'uglifier', '>= 4.1'
gem 'bootstrap-sass', '~> 3.3.7'
gem 'bootstrap-datepicker-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 6.0.0'
gem 'sass-rails', '>= 5'

gem 'tinymce-rails', '~> 4.6.4'

gem 'kaminari'
gem 'activerecord-session_store'

# For search and indexing
gem 'thinking-sphinx', '~> 4.0.0'
gem 'ts-delayed-delta', '2.1.0', :require => 'thinking_sphinx/deltas/delayed_delta'

gem 'htmlentities'

# For redis integration
gem 'redis'
# gem 'redis-rails', '>= 5.0.2'

# For easy cron scheduling
gem 'whenever', '~> 0.10.0', :require => false

group :development do
  gem 'web-console', '~> 3.5'
end

group :test, :development do
  gem 'better_errors', '~> 2.4.0'
  gem 'capybara', '2.18.0'
  gem 'capybara-webkit', '1.15.0'
  gem 'codacy-coverage', :require => false
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 4.10.0'
  gem 'faker', :git => 'https://github.com/stympy/faker.git', :branch => 'master'
  gem 'jasmine', '~> 3.1.0'
  gem 'jasmine_selenium_runner'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack-mini-profiler'
  gem 'rails-controller-testing'
  %w[rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support].each do |lib|
    gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => 'master'
  end
  # gem 'rspec-rails', '~> 3.7.2'
  gem 'rubocop', require: false
  gem 'shoulda-callback-matchers', '~> 1.1.4'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'spring', '~> 2.0.2'
  gem 'spring-commands-rspec'
end

gem 'seed_dump', :require => false
gem 'simplecov', :require => false, :group => :test

gem 'StreetAddress', :require => "street_address"
gem 'sequel', :require => false

gem 'validate_url', :git => 'https://github.com/perfectline/validates_url.git', :branch => 'master'
gem 'geocoder'

# used for screenshot capture
gem 'selenium-webdriver', '>= 3.11.0'
gem 'headless'

# used to connect to Rocket.Chat's mongo
gem 'mongo'

# used by Pages and Toolkit for Markdown->Html
gem 'redcarpet', '>= 3.4.0'

# google's recaptcha
gem "recaptcha", '>= 4.6.6', require: "recaptcha/rails"

# Used by `lib/cmp`
gem "roo", "~> 2.7.0", :require => false

# Used by NameSimilarity
gem 'text', '>= 1.3.1'


# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
