FactoryBot.define do
  factory :entity_version, class: PaperTrail::Version do
    item_type { 'Entity' }
    item_id { rand(10_000) }
    created_at { Time.current }
    whodunnit { '1' }
    event { 'update' }
    object_changes { PaperTrail::Serializers::YAML.dump("blurb" => ["original", "updated blurb"]) }
  end

  factory :relationship_version, class: PaperTrail::Version do
    entity1_id { rand(10_000) }
    entity2_id { rand(10_000) }
    created_at { Time.current }
    item_type { 'Relationship' }
    item_id { rand(10_000) }
    whodunnit { '1' }
    event { 'update' }
    object_changes { PaperTrail::Serializers::YAML.dump("start_date" => [nil, "2000-01-01"]) }
  end
end
