FactoryBot.define do
  sequence(:tag_id) { |n| n }

  factory :tag, class: Tag  do
    sequence(:id)
    sequence(:name) { |n| "tag-name#{n}" }
    sequence(:description) { |n| "description of tag-name#{n}" }
  end

  factory :oil_tag, class: Tag do
    name { 'oil' }
    description { "the reason for our planet's demise" }
  end

  factory :nyc_tag, class: Tag do
    name { 'nyc' }
    description { "anything related to New York City" }
    restricted { true }
  end

  factory :finance_tag, class: Tag do
    name { 'finance' }
    description { 'banks and such' }
  end

  factory :real_estate_tag, class: Tag do
    name { 'real-estate' }
    description { 'The real estate industry' }
  end

  trait :with_tag_id do
    id { generate(:tag_id) }
  end
end
