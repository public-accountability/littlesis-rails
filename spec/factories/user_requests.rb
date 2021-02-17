FactoryBot.define do
  factory :user_request do
    type { 'MergeRequest' }
    justification { Faker::TvShows::Seinfeld.quote }
    association :user
  end
end
