def css(*args)
  expect(rendered).to have_css(*args)
end

def not_css(*args)
  expect(rendered).not_to have_css(*args)
end

# thanks to https://stackoverflow.com/questions/3853098/turn-off-transactional-fixtures-for-one-spec-with-rspec-2
def without_transactional_fixtures(&block)
  self.use_transactional_fixtures = false

  before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  yield

  after(:all) do
    DatabaseCleaner.strategy = :transaction
  end
end
