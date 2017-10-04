FactoryGirl.define do
  sequence :relationship_id do |n|
    n + 100
  end

  factory :relationship_with_house, class: Relationship do
    # entity1_id 10551
    entity2_id 12884
    category_id 3
    description1 "Representative"
    description2 "Representative"
    start_date "2012-00-00"
    is_deleted false
  end

  factory :generic_relationship, class: Relationship do
    category_id 12
    id { generate(:relationship_id) }
  end

  factory :donation_relationship, class: Relationship do
    category_id 5
    id { generate(:relationship_id) }
  end

  factory :education_relationship, class: Relationship do
    category_id 2
    id { generate(:relationship_id) }
  end

  factory :position_relationship, class: Relationship do
    entity1_id 100
    entity2_id 200
    category_id Relationship::POSITION_CATEGORY
  end

  factory :ownership_relationship, class: Relationship do
    entity1_id 100 # hmm... why do we do this? is this good? (ag|Tue 03 Oct 2017)
    entity2_id 200
    category_id Relationship::OWNERSHIP_CATEGORY
  end

  factory :relationship, class: Relationship do
    association :entity, factory: :person, strategy: :build
    association :related, factory: :mega_corp_llc, strategy: :build
    id { generate(:relationship_id) }
  end

end
