FactoryBot.define do
  sequence :relationship_id do |n|
    n + 100
  end

  factory :relationship_with_house, class: Relationship do
    # entity1_id 10551
    entity2_id { 12_884 }
    category_id { 3 }
    description1 { "Representative" }
    description2 { "Representative" }
    start_date { "2012-00-00" }
    is_deleted { false }
  end

  factory :generic_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:generic] }
    id { generate(:relationship_id) }
  end

  factory :donation_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:donation] }
    id { generate(:relationship_id) }
  end

  factory :education_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:education] }
    id { generate(:relationship_id) }
  end

  factory :membership_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:membership] }
  end

  factory :family_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:family] }
  end

  factory :social_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:social] }
    id { generate(:relationship_id) }
  end

  factory :position_relationship, class: Relationship do
    entity1_id { 100 }
    entity2_id { 200 }
    category_id { RelationshipCategory.name_to_id[:position] }
  end

  factory :transaction_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:transaction] }
  end

  factory :lobbying_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:lobbying] }
  end

  factory :professional_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:professional] }
  end
  
  factory :ownership_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:ownership] }
  end

  factory :hierarchy_relationship, class: Relationship do
    category_id { RelationshipCategory.name_to_id[:hierarchy] }
  end

  factory :relationship, class: Relationship do
    association :entity, factory: :person, strategy: :build
    association :related, factory: :mega_corp_llc, strategy: :build
    id { generate(:relationship_id) }
  end

  factory :nys_donation_relationship, class: Relationship do
    description1 { 'NYS Campaign Contribution' }
    category_id { RelationshipCategory.name_to_id[:donation] }
  end

  factory :federal_donation_relationship, class: Relationship do
    description1 { 'Campaign Contribution' }
    category_id { RelationshipCategory.name_to_id[:donation] }
  end
end
