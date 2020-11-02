module Features
  module NoticeHelpers
    extend RSpec::Matchers::DSL

    matcher :show_success do |expected|
      match do |actual|
        expect(actual).to have_css(".alert.alert-success", text: expected)
      end
    end

    matcher :show_warning do |expected|
      match do |actual|
        expect(actual).to have_css(".alert.alert-warning", text: expected)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Features::NoticeHelpers, type: :feature
end
