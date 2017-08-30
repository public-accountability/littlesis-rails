FactoryGirl.define do
  factory :entity_finace_tagging, class: Tagging  do
    tag_id 1
    generate(:tagable_id)
    tagable_class Entity
  end
end
