FactoryBot.define do
  factory :external_relationship do
    external_data { nil }
    relationship { nil }
    dataset { 'iapd_schedule_a' }

    initialize_with { new(dataset: dataset) }
  end

  factory :external_relationship_schedule_a, class: 'ExternalRelationship' do
    association :external_data, factory: :external_data_schedule_a
    dataset { 'iapd_schedule_a' }
    category_id { 10 }

    initialize_with { new(dataset: dataset) }
  end
end
