FactoryBot.define do
  factory :legacy_address, class: 'LegacyAddress' do
    street1 { Faker::Address.street_name }
    city { Faker::Address.city }
    country_name { Faker::Address.country.slice(0, 50) }
  end
end
