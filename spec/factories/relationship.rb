FactoryGirl.define do
  factory :relationship_with_house, class: Relationship do
    # entity1_id 10551
    entity2_id 12884
    category_id 3
    description1 "Representative"
    description2 "Representative"
    start_date "2012-00-00"
    is_deleted false
  end

  factory :position_relationship, class: Relationship do
    entity1_id 100
    entity2_id 200
    category_id 1
  end

  factory :relationship, class: Relationship do
    association :entity, factory: :person, strategy: :build
    association :related, factory: :mega_corp_llc, strategy: :build
  end

end
