FactoryBot.define do
  factory :email do
    address { Faker::Internet.email }
  end
end
