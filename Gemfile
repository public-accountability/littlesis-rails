source 'https://rubygems.org'

gem 'rails', '7.0.2.2'

gem 'pg'
gem 'mysql2', '~> 0.5.2'
gem 'puma', '>= 5'
gem 'redis'
gem 'scenic'

# Utilities
gem 'csv'
gem 'bootsnap', '>= 1.4.3', require: false
gem 'nokogiri'
gem 'zeitwerk'
gem 'rexml'

# Rack middleware
gem 'rack-rewrite', '~> 1.5.1'

# users and authentication
gem 'devise', '~> 4.7'

# Versioning
gem 'paper_trail'

# Pagination
gem 'kaminari'
gem 'good_job', '>= 2.6.2'

# Assets and images
gem 'image_processing'
gem 'mini_magick'
gem 'sassc-rails'
gem 'sprockets', '~> 4'
gem 'turbo-rails', '> 0.8', '< 7.0.0'
gem 'stimulus-rails'
gem 'jsbundling-rails'

# Search
gem 'thinking-sphinx', '~> 5.1'

# handle currencies etc
gem 'money'

gem 'datagrid'

gem 'validate_url', '>= 1.0.13'

# Used by StringSimilarity
gem 'text', '>= 1.3.1'

# Track exceptions
gem 'rollbar'

group :test do
  gem 'capybara', '>= 3.14.0'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'factory_bot_rails', '~> 6.0'
  gem 'rails-controller-testing'
  gem 'rspec-benchmark'
  gem 'rspec'
  gem 'rspec-rails', '>= 4.0.1'
  gem 'rspec_junit_formatter'
  gem 'shoulda-callback-matchers', '~> 1.1.4'
  gem 'shoulda-matchers', '>= 4.0.0'
  gem 'simplecov', require: false
end

group :development do
  gem "debug", ">= 1.0.0"
  gem 'rack-mini-profiler', require: false
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'web-console'
  gem 'better_errors'
  gem 'solargraph', require: false
end

group :test, :development do
  gem 'memory_profiler'
  gem 'faker', '>= 2.13'
  gem 'selenium-webdriver', '>= 4.0.0'
end

# Used by lib/
gem 'roo', "~> 2.8.1", require: false
gem 'rubyzip', require: false
gem 'sqlite3', require: false
gem 'parallel', require: false
