FactoryBot.define do
  factory :image_deletion_request do
    justification { Faker::Lorem.sentence }
  end
end
