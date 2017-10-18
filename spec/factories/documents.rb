FactoryGirl.define do
  factory :document do
    url { Faker::Internet.unique.url } 
    name { Faker::Lorem.sentence }
  end
end
