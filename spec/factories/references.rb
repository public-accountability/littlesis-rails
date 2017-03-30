FactoryGirl.define do
  factory :ref, class: Reference do
    object_model 'list'
  end

  factory :entity_ref, class: Reference do
    object_model 'Entity'
    object_id { rand(100) }
    name 'reference name'
    source 'https://littlesis.org'
  end
end
