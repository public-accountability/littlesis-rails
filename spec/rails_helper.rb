# Only generate coverage report if environment variable is set
if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter 'lib/tasks'
    add_filter 'lib/scripts'
  end

  if ENV['TRAVIS']
    require 'codecov'
    SimpleCov.formatter = SimpleCov::Formatter::Codecov
  end
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is not set to test!") unless Rails.env == 'test'
require 'rails/all'
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
  config.expect_with :rspec
  config.mock_with :rspec

  # these run inside an example (ie: it block)
  config.include RspecHelpers::ExampleMacros
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include Devise::Test::ControllerHelpers, :type => :view
  config.include Warden::Test::Helpers
  config.include FactoryBot::Syntax::Methods
  config.include FeatureExampleMacros, :type => :feature
  config.include RequestExampleMacros, :type => :request
  config.include CapybaraHelpers, :type => :feature
  config.include NetworkAnalysisExampleHelper, :network_analysis_helper
  config.include MergingExampleMacros, :merging_helper
  config.include SphinxTestHelper, :sphinx

  # these run inside example groups (ie: describe blocks)
  config.extend RspecHelpers::GroupMacros
  config.extend ControllerMacros, :type => :controller
  config.extend FeatureGroupMacros, :type => :feature
  config.extend RequestGroupMacros, :type => :request
  config.extend ListHelpersForExampleGroups, :list_helper
  config.extend TaggingHelpers, :tagging_helper
  config.extend TagSpecHelper, :tag_helper
  config.extend PaginationExampleGroupHelper, :pagination_helper
  config.extend MergingGroupMacros, :merging_helper
  config.extend NameParserMacros, :name_parser_helper
  config.extend ExternalLinkGroupHelper, :external_link

  # Running tests in database transactions
  #
  # Note that this being false does not actually mean we are not using transactions;
  # it just tells RSpec to tell Rails not to handle transactions for tests;
  # DatabaseCleaner actually handles the transactions.
  config.use_transactional_fixtures = false

  # DatabaseCleaner.strategy = :transaction

  config.before(:each) do |example|
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end
  end

  # For transaction strategy, start the database cleaner before each test start
  # Note that some individual tests also depend on local invocations of DatabaseCleaner
  # within before(:all) blocks etc.
  config.before(:each) do
    DatabaseCleaner.start
  end

  # Clean the db after each test start
  config.after(:each) do |example|
    DatabaseCleaner.clean
    if example.metadata[:js]
      ApplicationRecord.connection.execute("ALTER TABLE `users` AUTO_INCREMENT = 1")
      ActiveRecord::Tasks::DatabaseTasks.load_seed
    end
  end


  config.around(:each, :caching) do |example|
    caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = example.metadata[:caching]
    example.run
    ActionController::Base.perform_caching = caching
  end

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
end
