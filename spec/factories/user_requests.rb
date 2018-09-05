FactoryBot.define do
  factory :user_request do
    type { 'MergeRequest' }
    justification { Faker::Seinfeld.quote }
    association :user, factory: :really_basic_user
  end
end
