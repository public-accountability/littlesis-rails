FactoryBot.define do
  factory :address do
    street1 { "MyText" }
    street2 { "MyText" }
    street3 { "MyText" }
    city { "MyText" }
    state { "MyString" }
    country { "MyString" }
    normalized_address { "MyText" }
    location { nil }
  end
end
