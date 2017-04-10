FactoryGirl.define do
  factory :link, class: Link do
    sequence(:id)
    entity1_id { rand(1000) }
    entity2_id { rand(1000) }
    relationship_id { rand(100) }
    is_reverse false
  end
end
