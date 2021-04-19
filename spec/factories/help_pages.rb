FactoryBot.define do
  factory :help_page do
    name { Faker::Lorem.sentence.parameterize }
    title { Faker::Lorem.sentence }
    last_user_id { 1 }
    content { "<h1>#{Faker::Lorem.sentence}</h1>" }
  end
end
