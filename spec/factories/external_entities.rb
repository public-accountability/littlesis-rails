FactoryBot.define do
  factory :external_entity do
    dataset { "nycc" }

    initialize_with { new(dataset: dataset) }
  end

  factory :external_entity_nycc, class: 'ExternalEntity' do
    dataset { "nycc" }

    initialize_with { new(dataset: dataset) }
  end

  factory :external_entity_iapd_advisor, class: 'ExternalEntity' do
    dataset { "iapd_advisors" }
    association :external_data, factory: :external_data_iapd_advisor, strategy: :build

    # See https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#custom-strategies
    # for an explanation of why this is required.
    initialize_with { new(dataset: dataset) }
  end
end
