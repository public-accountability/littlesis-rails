# RSpec.configure do |config|
#   # Truncating all the tables before test suite start
#   config.before(:suite) do
#     DatabaseCleaner.clean_with(:truncation)
#   end

#   # Use transaction strategy to clean the db before each test start
#   config.before(:each) do
#     DatabaseCleaner.strategy = :transaction
#   end

#   # For testing javascript. Use truncation strategy to clean the db before each
#   # test start
#   config.before(:each, js: true) do
#     DatabaseCleaner.strategy = :truncation
#   end

#   # For transaction strategy, start the database cleaner before each test start
#   config.before(:each) do
#     DatabaseCleaner.start
#   end

#   # Clean the db after each test start
#   config.after(:each) do
#     DatabaseCleaner.clean
#   end
# end
