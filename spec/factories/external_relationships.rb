FactoryBot.define do
  factory :external_relationship do
    external_data { nil }
    relationship { nil }
    dataset { nil }
  end

  factory :external_relationship_iapd_owner, class: 'ExternalRelationship' do
    external_data { nil }
    dataset { 'iapd_owners' }
  end
end
