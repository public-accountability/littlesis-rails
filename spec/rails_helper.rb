# Only generate coverage report if environment variable is set
if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
abort("The Rails environment is running in development mode!") if Rails.env.development?
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
  # these run inside an example (ie: it block)
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include Devise::Test::ControllerHelpers, :type => :view
  config.include Warden::Test::Helpers
  config.include FactoryBot::Syntax::Methods
  config.include FeatureExampleMacros, :type => :feature
  config.include RequestExampleMacros, :type => :request
  config.include NetworkAnalysisExampleHelper, :network_analysis_helper
  config.include MergingExampleMacros, :merging_helper

  # these run inside example groups (ie: describe blocks)
  config.extend ControllerMacros, :type => :controller
  config.extend FeatureGroupMacros, :type => :feature
  config.extend ListHelpersForExampleGroups, :list_helper
  config.extend TaggingHelpers, :tagging_helper
  config.extend TagSpecHelper, :tag_helper
  config.extend PaginationExampleGroupHelper, :pagination_helper
  config.extend MergingGroupMacros, :merging_helper

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

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

  # https://github.com/kucaahbe/rspec-html-matchers
  config.include RSpecHtmlMatchers

  Capybara.ignore_hidden_elements = false

  # config.before(:suite) do
  #   Page.delete_all
  #   ToolkitPage.delete_all
  #   User.delete_all
  #   SfGuardUser.delete_all
  #   SfGuardUserPermission.delete_all
  # end

  DatabaseCleaner.strategy = :transaction

  # config.before(:all) do
  #   Faker::Random.seed = config.seed
  #end

  # For transaction strategy, start the database cleaner before each test start
  config.before(:each) do
#    Faker::Random.reset!
    DatabaseCleaner.start
  end

  # Clean the db after each test start
  config.after(:each) do
    DatabaseCleaner.clean
  end
end
