# Only generate coverage report if environment variable is set
if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
abort("The Rails environment is running in development mode!") if Rails.env.development?
require 'spec_helper'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'capybara/rspec'

require 'devise'
require 'paper_trail/frameworks/rspec'
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # devise helpers
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include Devise::Test::ControllerHelpers, :type => :view
  config.include Warden::Test::Helpers

  config.extend ControllerMacros, :type => :controller
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = false

  # config.before :each do |example|
  #   # Configure and start Sphinx for request specs
  #   if example.metadata[:type] == :request
  #     ThinkingSphinx::Test.init
  #     ThinkingSphinx::Test.start index: false
  #   end

  #   # Disable real-time callbacks if Sphinx isn't running
  #   ThinkingSphinx::Configuration.instance.settings['real_time_callbacks'] =
  #     (example.metadata[:type] == :request)
  # end

  # config.after(:each) do |example|
  #   # Stop Sphinx and clear out data after request specs
  #   if example.metadata[:type] == :request
  #     ThinkingSphinx::Test.stop
  #     ThinkingSphinx::Test.clear
  #   end
  # end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Shoulda-matchers configuration
  # https://github.com/thoughtbot/shoulda-matchers
  Shoulda::Matchers.configure do |conf|
    conf.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  config.include RSpecHtmlMatchers

  config.around type: :feature do |example|
    Headless.ly do
      example.run
    end
  end

  # DatabaseCleaner Configuration
  # See: https://github.com/DatabaseCleaner/database_cleaner#rspec-with-capybara-example

  DO_NOT_TRUNCATE_THESE_TABLES = %w(extension_definition ls_list sf_guard_permission relationship_category degree)
  config.use_transactional_fixtures = false

  config.before(:suite) do
    if config.use_transactional_fixtures?
      raise(<<-MSG)
        Delete line `config.use_transactional_fixtures = true` from rails_helper.rb
        (or set it to false) to prevent uncommitted transactions being used in
        JavaScript-dependent specs.

        During testing, the app-under-test that the browser driver connects to
        uses a different database connection to the database connection used by
        the spec. The app's database connection would not be able to access
        uncommitted transaction data setup over the spec's database connection.
      MSG
    end
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation, {:except => DO_NOT_TRUNCATE_THESE_TABLES.push('sf_guard_user') }
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = :transaction
    if example.metadata[:use_truncation]
      DatabaseCleaner.strategy = :truncation, {:except => DO_NOT_TRUNCATE_THESE_TABLES }
    end
  end

  config.before(:each, type: :feature) do
    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so continue to use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    if !driver_shares_db_connection_with_specs
      # Driver is probably for an external browser with an app
      # under test that does *not* share a database connection with the
      # specs, so use truncation strategy.
      DatabaseCleaner.strategy = :truncation, {:except => DO_NOT_TRUNCATE_THESE_TABLES }
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do |example|
    DatabaseCleaner.clean
    #if example.metadata[:use_truncation]
      # We clear the SfGuardUser table during the truncation step, so
      # the system user must be re-added
      #SfGuardUser.create({id: 1, username: "system@littlesis.org", password: 'password', salt:''})
    #end
  end
  
end

###########################
# Capybara Configuration  #
###########################

Capybara.ignore_hidden_elements = false
Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  config.block_unknown_urls
end
