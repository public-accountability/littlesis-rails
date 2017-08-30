FactoryGirl.define do
  
  factory :open_tagging, class: Tagging  do
    tag_id 1
    sequence(:tagable_id)
    tagable_class Entity
  end

  factory :closed_tagging, class: Tagging do
    tag_id 2
    sequence(:tagable_id)
    tagable_class Entity
  end
end
