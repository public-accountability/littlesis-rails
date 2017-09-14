FactoryGirl.define do
  
  factory :tagging, class: Tagging do
    sequence(:id)
    sequence(:tag_id)
    sequence(:tagable_id)
    sequence(:tagable_class) do |n|
      Tagable.classes[n % Tagable.classes.size]
    end
  end
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
