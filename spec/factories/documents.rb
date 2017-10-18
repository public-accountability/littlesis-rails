FactoryGirl.define do
  factory :document do
    url { Faker::Internet.unique.url } 
    name { Faker::Lorem.sentence }
  end

  factory :fec_document, class: Document do
    url { Faker::Internet.unique.url }
    name { Faker::Lorem.sentence }
    ref_type Document::REF_TYPE_LOOKUP.fetch(:fec)
  end
end


