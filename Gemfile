source 'https://rubygems.org'

gem 'rails', '6.0.3.3'

gem 'mysql2', '~> 0.5.2'
gem 'puma', '>= 4.2.0'
gem 'redis'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.3', require: false

# Rack middleware
gem 'rack-rewrite', '~> 1.5.1'

# users and authentication
gem 'devise', '~> 4.7'
gem 'activerecord-session_store'

# Versioning
gem 'paper_trail', '~> 11'

# Pagination
gem 'kaminari'

# Delayed job
gem 'daemons' # Required by delayed_job
gem 'delayed_job', '~> 4.1'
gem 'delayed_job_active_record', '>= 4.1.3'

# Assets and images
gem 'bootstrap', '>= 4.3.1'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 6.0.0'
gem 'mini_magick'
gem 'sassc-rails'
gem 'sprockets', '~> 3.0'
gem 'uglifier', '>= 4.1'
gem 'webpacker', '>= 4.0.2'

# Search
gem 'thinking-sphinx', '~> 4.4'
gem 'ts-delayed-delta', '2.1.0', :require => 'thinking_sphinx/deltas/delayed_delta'

# Cron
gem 'whenever', '~> 1.0.0', :require => false

# handle currencies etc
gem 'money'

group :test do
  gem 'codecov', :require => false
  gem 'simplecov', :require => false
end

group :development do
  gem 'better_errors', '>= 2.5.0'
  gem 'memory_profiler'
  gem 'rack-mini-profiler', require: false
  gem 'web-console'
end

group :test, :development do
  gem 'capybara', '>= 3.14.0'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'factory_bot_rails', '~> 6.0'
  gem 'faker', '>= 2.13'
  gem 'pry', '>= 0.12.0'
  gem 'pry-byebug'
  gem 'pry-doc', require: false
  gem 'pry-rails', '>= 0.3.7'
  gem 'rails-controller-testing'
  gem 'rspec-rails', '>= 4.0.1'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'shoulda-callback-matchers', '~> 1.1.4'
  gem 'shoulda-matchers', '>= 4.0.0'
  gem 'spring'
  gem 'spring-commands-rspec'
end

gem 'validate_url', :git => 'https://github.com/perfectline/validates_url.git', :branch => 'master'

# used for screenshot capture
gem 'selenium-webdriver', '>= 3.11.0'

# used by Pages and Toolkit for Markdown->Html
gem 'redcarpet', '>= 3.4.0'

# Used by `lib/cmp`
gem "roo", "~> 2.8.1", :require => false

# Used by StringSimilarity
gem 'text', '>= 1.3.1'

gem 'httparty', '>= 0.16.2'

gem 'nokogiri'
gem 'rubyzip', :require => false
gem 'sqlite3', :require => false
