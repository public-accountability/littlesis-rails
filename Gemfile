source 'https://rubygems.org'

gem 'rails', '4.2.8'
gem 'mysql2', '~> 0.3.21'

# users and authentication
gem 'devise', '~> 4.2'

# image uploading with amazon s3 storage
gem 'carrierwave'
gem 'mini_magick'
gem "fog-aws"  #  "~> 1.3.1"

gem 'sass-rails', '>= 3.2'
gem 'asset_sync'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', platforms: :ruby
  gem 'uglifier', '>= 1.0.3'
end

#  Nov 2016: Switch to Bootstrap
gem 'bootstrap-sass', '~> 3.3.7'

gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 6.0.0'
gem 'bootstrap-datepicker-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

gem 'aws-sdk', '< 2.0'
gem 'dimensions'
gem 'fastimage'
gem 'nilify_blanks'

gem 'bootsy', :git => "https://github.com/littlesis-org/bootsy.git"
gem 'tinymce-rails', '< 4.0'

gem 'bettertabs'
gem 'kaminari'
gem 'activerecord-session_store'

# For search and indexing
gem 'thinking-sphinx', '~> 3.2.0'
gem 'delayed_job_active_record'
gem 'ts-delayed-delta', '2.0.2', :require => 'thinking_sphinx/deltas/delayed_delta'

gem 'daemons'
gem 'twitter-typeahead-rails', '~> 0.9.3'
gem 'php-serialize'
gem 'htmlentities'

# For memcached integration
gem 'dalli'

# For redis integration
gem 'redis-rails'

# For easy cron scheduling
gem 'whenever', '~> 0.9.7', :require => false

# used in utility/vertical_response.rb
gem 'soap4r-ruby1.9'

# To use debugger
# gem 'debugger'

group :development do
  gem 'web-console', '~> 2.0'
end

group :test, :development do
  gem 'better_errors', '~> 2.1.1'
  gem 'capybara', '2.13.0'
  gem 'capybara-webkit', '1.14.0'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'jasmine', '~> 2.6.0'
  gem 'pry'
  gem 'pry-rails'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'seed_dump'
  gem 'shoulda-callback-matchers', '~> 1.1.4'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'spring-commands-rspec'
end

gem 'simplecov', :require => false, :group => :test

gem 'sprockets', '~> 3.0'
gem 'twitter'
gem 'poltergeist'
gem 'mechanize'
gem 'StreetAddress', :require => "street_address"
gem 'sequel', :require => false
gem 'rmagick'

gem 'paper_trail', '5.2.3'

# no longer needed for
# gem 'foreigner'

gem 'validate_url'
gem 'geocoder'
gem 'rack-mini-profiler'

# gem 'ruby-opencv'
# gem "passenger"

# used for screenshot capture
gem 'selenium-webdriver', '>= 3.3.0'
gem 'headless'

# used to connet to Rocket.Chat's mongo
gem 'mongo'

gem 'redcarpet', '>= 3.4.0'
