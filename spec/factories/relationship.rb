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
end
