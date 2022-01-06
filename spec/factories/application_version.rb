FactoryBot.define do
  factory :entity_version, class: 'ApplicationVersion' do
    item_type { 'Entity' }
    item_id { rand(10_000) }
    entity1_id { item_id }
    created_at { Time.current }
    whodunnit { '1' }
    event { 'update' }
    object_changes { PaperTrail::Serializers::YAML.dump("blurb" => ["original", "updated blurb"]) }
  end

  factory :relationship_version, class: 'ApplicationVersion' do
    entity1_id { Faker::Number.unique.number(digits: 6).to_i }
    entity2_id { Faker::Number.unique.number(digits: 6).to_i }
    created_at { Time.current }
    item_type { 'Relationship' }
    item_id { rand(10_000) }
    whodunnit { '1' }
    event { 'update' }
    object_changes { PaperTrail::Serializers::YAML.dump("start_date" => [nil, "2000-01-01"]) }
  end

  factory :page_version, class: 'ApplicationVersion' do
    created_at { Time.current }
    item_type { 'Page' }
    item_id { rand(10_000) }
    whodunnit { '1' }
    event { 'create' }
  end
end
