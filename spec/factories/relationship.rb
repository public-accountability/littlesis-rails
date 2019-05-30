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
    category_id { Relationship::GENERIC_CATEGORY }
    id { generate(:relationship_id) }
  end

  factory :donation_relationship, class: Relationship do
    category_id { Relationship::DONATION_CATEGORY }
    id { generate(:relationship_id) }
  end

  factory :education_relationship, class: Relationship do
    category_id { Relationship::EDUCATION_CATEGORY }
    id { generate(:relationship_id) }
  end

  factory :membership_relationship, class: Relationship do
    category_id { Relationship::MEMBERSHIP_CATEGORY }
  end

  factory :family_relationship, class: Relationship do
    category_id { Relationship::FAMILY_CATEGORY }
  end

  factory :social_relationship, class: Relationship do
    category_id { Relationship::SOCIAL_CATEGORY }
    id { generate(:relationship_id) }
  end

  factory :position_relationship, class: Relationship do
    entity1_id { 100 }
    entity2_id { 200 }
    category_id { Relationship::POSITION_CATEGORY }
  end

  factory :transaction_relationship, class: Relationship do
    category_id { Relationship::TRANSACTION_CATEGORY }
  end

  factory :lobbying_relationship, class: Relationship do
    category_id { Relationship::LOBBYING_CATEGORY }
  end

  factory :professional_relationship, class: Relationship do
    category_id { Relationship::PROFESSIONAL_CATEGORY }
  end
  
  factory :ownership_relationship, class: Relationship do
    category_id { Relationship::OWNERSHIP_CATEGORY }
  end

  factory :hierarchy_relationship, class: Relationship do
    category_id { Relationship::HIERARCHY_CATEGORY }
  end

  factory :relationship, class: Relationship do
    association :entity, factory: :person, strategy: :build
    association :related, factory: :mega_corp_llc, strategy: :build
    id { generate(:relationship_id) }
  end

  factory :nys_donation_relationship, class: Relationship do
    description1 { 'NYS Campaign Contribution' }
    category_id { Relationship::DONATION_CATEGORY }
  end

  factory :federal_donation_relationship, class: Relationship do
    description1 { 'Campaign Contribution' }
    category_id { Relationship::DONATION_CATEGORY }
  end
end
