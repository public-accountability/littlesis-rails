FactoryBot.define do
  factory :fec_committee, class: 'ExternalDataset::FECCommittee' do
    cmte_id { "H#{Faker::Number.unique.number}" }
    cmte_nm { "#{Faker::Lorem.characters(number: 5)} Committee" }
    fec_year { 2020 }
  end

  factory :fec_contribution, class: 'ExternalDataset::FECContribution' do
    sub_id { Faker::Number.unique.number }
    association :fec_committee, factory: :fec_committee
    fec_year { 2020 }
  end
end
