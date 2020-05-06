FactoryBot.define do
  factory :external_entity do
  end

  factory :external_entity_iapd_advisor, class: 'ExternalEntity' do
    dataset { "iapd_advisors" }
    association :external_data, factory: :external_data_iapd_advisor, strategy: :build
  end
end
