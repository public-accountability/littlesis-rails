FactoryBot.define do
  factory :phone do
    number { Faker::PhoneNumber.phone_number }
    type 'phone'
  end
end
