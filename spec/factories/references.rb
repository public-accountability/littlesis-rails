FactoryGirl.define do
  factory :ref, class: Reference do
    object_model 'list'
  end

  factory :entity_ref, class: Reference do
    object_model 'Entity'
    object_id { rand(100) }
    sequence(:id)
    name 'reference name'
    sequence(:source) { |n| "https://littlesis.org/#{n}" }
  end
end
