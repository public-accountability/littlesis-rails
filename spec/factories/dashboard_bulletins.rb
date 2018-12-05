FactoryBot.define do
  factory :dashboard_bulletin do
    markdown { Faker::Markdown.sandwich }
    title { Faker::Kpop.solo }
  end
end
