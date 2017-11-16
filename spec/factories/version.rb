FactoryBot.define do
  factory :entity_version, class: PaperTrail::Version do
    sequence(:id)
    created_at { Time.now }
    event 'Update'
    object_changes PaperTrail::Serializers::YAML.dump({"blurb" => ["original", "updated blurb"]})
  end

  factory :relationship_version, class: PaperTrail::Version do
    sequence(:id)
    sequence(:entity1_id)
    sequence(:entity2_id) { |n| n + 1000 }
    created_at { Time.now }
    event 'Update'
    object_changes PaperTrail::Serializers::YAML.dump({"start_date" => [nil, "2000-01-01"]})
  end
end
