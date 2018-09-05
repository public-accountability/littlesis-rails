FactoryBot.define do
  factory :cmp_entity do
    entity { nil }
    cmp_id { 1 }
    entity_type { 0 }
  end

  factory :cmp_entity_org, class: CmpEntity do
    cmp_id { Faker::Number.unique.number(6) }
    entity_type { 0 }
  end

  factory :cmp_entity_person, class: CmpEntity do
    cmp_id { Faker::Number.unique.number(6) }
    entity_type { 1 }
  end
end
