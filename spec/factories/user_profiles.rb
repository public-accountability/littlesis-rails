# frozen_string_literal: true

FactoryBot.define do
  factory :user_profile do
    user { nil }
    name { Faker::Name.name }
    reason { Faker::Lorem.sentence }
  end
end
