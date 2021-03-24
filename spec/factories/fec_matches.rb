FactoryBot.define do
  factory :entity_donor_fec_match, class: 'Entity' do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    primary_ext { 'Person' }
  end

  factory :fec_match do
    association :fec_contribution, factory: :fec_contribution
    association :donor, factory: :entity_donor_fec_match
  end
end
