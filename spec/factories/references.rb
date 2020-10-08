FactoryBot.define do
  factory :reference, class: Reference do
    referenceable_type { 'Relationship' }
    sequence(:id)
    sequence(:referenceable_id)
    association :document, factory: :document_with_id, strategy: :build
  end

  factory :ref, class: Reference do
    object_model { 'list' }
  end

  factory :entity_ref, class: Reference do
    referenceable_type { 'Entity' }
    sequence(:id)
    sequence(:referenceable_id)
    association :document, factory: :document_with_id, strategy: :build
  end

  factory :relationship_ref, class: Reference do
    object_model { 'Relationship' }
    object_id { rand(100) }
    sequence(:id)
    name { 'reference name' }
    sequence(:source) { |n| "https://littlesis.org/#{n}" }
  end
end
