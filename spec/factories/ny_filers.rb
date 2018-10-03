FactoryBot.define do
  factory :ny_filer do
    filer_id { 'ABC' }
    name { Faker::Company.name }
  end
end
