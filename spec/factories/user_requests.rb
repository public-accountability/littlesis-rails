FactoryBot.define do
  factory :user_request do
    type { 'MergeRequest' }
    justification { Faker::TvShows::Seinfeld.quote }
    association :user, factory: :really_basic_user
  end
end
