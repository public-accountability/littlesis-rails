FactoryBot.define do
  factory :user_request do
    type 'MergeRequest'
    association :user, factory: :really_basic_user
  end
end
