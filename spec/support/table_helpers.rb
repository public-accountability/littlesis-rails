module Features
  module TableHelpers
    extend RSpec::Matchers::DSL

    def within_row(name, &block)
      within(:xpath, "//tr[td='#{name}']", &block)
    end
  end
end

RSpec.configure do |config|
  config.include Features::TableHelpers, type: :feature
end
