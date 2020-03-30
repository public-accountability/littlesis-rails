FactoryBot.define do
  factory :link, class: Link do
    sequence(:id)
    entity1_id { rand(1000) }
    entity2_id { rand(1000) }
    relationship_id { rand(1000) }
    is_reverse { false }
    category_id { rand(1..12) }
  end
end
