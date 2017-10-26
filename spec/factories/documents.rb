FactoryGirl.define do
  factory :document do
    url { Faker::Internet.unique.url }
    name { Faker::Lorem.sentence }
  end

  factory :document_with_id, class: Document do
    url { Faker::Internet.unique.url }
    name { Faker::Lorem.sentence }
    sequence(:id)
  end

  factory :fec_document, class: Document do
    url { Faker::Internet.unique.url }
    name { Faker::Lorem.sentence }
    ref_type Document::REF_TYPE_LOOKUP.fetch(:fec)
  end
end


