FactoryBot.define do
  factory :location do
    city { "MyText" }
    country { "MyText" }
    subregion { "MyText" }
    region { 1 }
    lat { "9.99" }
    lng { "9.99" }
    references { "" }
  end
end
