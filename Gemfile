source 'https://rubygems.org'

gem 'rails', '4.2.8'
gem 'mysql2', '~> 0.3.21'

# Rack middleware
gem 'rack-rewrite', '~> 1.5.1'

# users and authentication
gem 'devise', '~> 4.2'

# Versioning
gem 'paper_trail', '7.1.3'

# image uploading & processing
gem 'carrierwave'
gem 'mini_magick'
gem 'rmagick'
gem 'aws-sdk', '< 2.0'

# Required by delayed_job
gem 'daemons'

gem 'sprockets', '~> 3.0'
gem 'asset_sync', '~> 2.1.0'
gem "fog-aws"

# asset gems
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
gem 'uglifier', '>= 1.0.3'

gem 'bootstrap-sass', '~> 3.3.7'
gem 'bootstrap-datepicker-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 6.0.0'
gem 'sass-rails', '>= 3.2'

gem 'tinymce-rails', '~> 4.6.4'

gem 'bettertabs'
gem 'kaminari'
gem 'activerecord-session_store'

# For search and indexing
gem 'thinking-sphinx', '~> 3.2.0'
gem 'delayed_job_active_record', '>= 4.1.2'
gem 'ts-delayed-delta', '2.0.2', :require => 'thinking_sphinx/deltas/delayed_delta'

gem 'htmlentities'

# For redis integration
gem 'redis-rails', '>= 5.0.2'

# For easy cron scheduling
gem 'whenever', '~> 0.9.7', :require => false

# used in utility/vertical_response.rb
gem 'soap4r-ruby1.9'

group :development do
  gem 'web-console', '~> 2.0'
end

group :test, :development do
  gem 'better_errors', '~> 2.4.0'
  gem 'capybara', '2.13.0'
  gem 'capybara-webkit', '1.14.0'
  gem 'database_cleaner'
  gem 'factory_bot_rails', '~> 4.8.2'
  gem 'faker', :git => 'https://github.com/stympy/faker.git', :branch => 'master'
  gem 'jasmine', '~> 2.8.0'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rack-mini-profiler'
  gem 'rspec-html-matchers', '~> 0.9.0'
  gem 'rspec-rails', '~> 3.6.1'
  gem 'rubocop', require: false
  gem 'shoulda-callback-matchers', '~> 1.1.4'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'spring', '~> 2.0.2'
  gem 'spring-commands-rspec'
end

gem 'seed_dump', :require => false
gem 'simplecov', :require => false, :group => :test

gem 'twitter'

gem 'StreetAddress', :require => "street_address"
gem 'sequel', :require => false

gem 'validate_url', :git => 'https://github.com/perfectline/validates_url.git', :branch => 'master'
gem 'geocoder'

# used for screenshot capture
gem 'selenium-webdriver', '>= 3.3.0'
gem 'headless'

# used to connect to Rocket.Chat's mongo
gem 'mongo'

# used by Pages and Toolkit for Markdown->Html
gem 'redcarpet', '>= 3.4.0'

# google's recaptcha
gem "recaptcha", '>= 4.6.2', require: "recaptcha/rails"
