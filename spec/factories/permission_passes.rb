FactoryBot.define do
  factory :permission_pass do
    event_name { Faker::Lorem.sentence }
    token { Faker::Crypto.md5 }
    valid_to { 2.hours.from_now }
    role { User.roles[:editor] }
  end
end
