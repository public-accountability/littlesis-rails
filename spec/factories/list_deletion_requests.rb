FactoryBot.define do
  factory :list_deletion_request do
    justification { Faker::Lorem.sentence }
  end
end
