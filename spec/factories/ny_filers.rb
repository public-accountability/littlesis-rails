FactoryBot.define do
  factory :ny_filer do
    filer_id { SecureRandom.hex(4) }
    name { Faker::Company.name }
  end
end
