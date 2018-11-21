# frozen_string_literal: true

FactoryBot.define do
  factory :user_profile do
    user { nil }
    name_first { Faker::Name.first_name }
    name_last { Faker::Name.last_name }
    reason { Faker::Lorem.sentence }
  end
end
