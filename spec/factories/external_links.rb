FactoryBot.define do
  factory :external_link do
    link_type { 1 }
    entity_id { "" }
    link_id { "MyString" }
  end

  factory :sec_external_link, class: ExternalLink do
    link_type { 1 }
    entity_id { rand(1000) }
    link_id { rand(10_000).to_s }
  end

  factory :wikipedia_external_link, class: ExternalLink do
    link_type { 2 }
    entity_id { rand(1000) }
    link_id { Faker::Cat.breed.tr(' ', '_') }
  end

  factory :twitter_external_link, class: ExternalLink do
    link_type { 3 }
    entity_id { rand(1000) }
    link_id { Faker::Internet.unique.username }
  end
end
