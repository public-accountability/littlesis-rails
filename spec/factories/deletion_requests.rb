FactoryBot.define do
  factory :deletion_request, class: DeletionRequest do
    association :user, factory: :really_basic_user
    association :entity, factory: :entity_person
  end
end
