FactoryBot.define do
  factory :merge_request do
    association :user, factory: :really_basic_user
    association :source, factory: :entity_person
    association :dest, factory: :entity_person
  end
end
