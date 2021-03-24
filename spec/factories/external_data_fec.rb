FactoryBot.define do
  factory :fec_contribution do
    sub_id { Faker::Number.unique.number }
  end
end
