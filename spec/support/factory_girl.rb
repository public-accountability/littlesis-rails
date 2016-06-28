RSpec.configure do |config|
  # If you do not include FactoryGirl::Syntax::Methods in your test suite, then
  # all factory_girl methods will need to be prefaced with FactoryGirl.
  config.include FactoryGirl::Syntax::Methods

  # The follow setting will ensure all the factories are valid. Since it may end
  # up persisting some records to the database, we use Database Cleaner to
  # restore the state of the database after we've linted our factories.
  #config.before(:suite) do
  #   begin
  #     DatabaseCleaner.start
  #     FactoryGirl.lint
  #   ensure
  #     DatabaseCleaner.clean
  #   end
  # end
end
