FactoryBot.define do
  factory :external_relationship do
    external_data { nil }
    relationship { nil }
    dataset { nil }
  end

  factory :external_relationship_iapd_owner, class: 'ExternalRelationship' do
    association :external_data, factory: :external_data_iapd_owner
    dataset { 'iapd_owners' }
    category_id { 10 }
  end
end
