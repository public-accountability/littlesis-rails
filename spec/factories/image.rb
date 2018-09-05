FactoryBot.define do
  sequence :image_entity_id do |n|
    n
  end

  sequence :filename do |n|
    "image#{n}.png"
  end

  factory :image, class: Image do
    sequence(:id)
    is_featured { false }
    is_deleted { false }
    entity_id { generate(:image_entity_id) }
    filename { generate(:filename) }
    title { "title" }
  end
end
