FactoryBot.define do
  factory :article do
    url { Faker::Internet.unique.url }
    title { Faker::Lorem.sentence }
    created_by_user_id '1'
  end
end
