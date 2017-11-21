FactoryBot.define do
  factory :phone do
    number { Faker::PhoneNumber.phone_number.slice(0,16) }
    type 'phone'
  end
end
