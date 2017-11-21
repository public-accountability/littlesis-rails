FactoryBot.define do
  factory :address do
    street1 { Faker::Address.street_name  }
    city { Faker::Address.city }
    country_name { Faker::Address.country }
  end
end
