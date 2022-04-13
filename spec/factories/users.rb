FactoryBot.define do
  sequence :user_email do |n|
    "user_#{n}@littlesis.org"
  end

  factory :user, class: 'User' do
    username { Faker::Internet.unique.user_name(specifier: 5).tr('.', '') }
    email { Faker::Internet.unique.email }
    about_me { Faker::Movie.quote }
    role { 'user' }
    default_network_id { 79 }
    confirmed_at { 1.hour.ago }
  end

  # sub-factory pattern. see: https://devhints.io/factory_bot
  factory :really_basic_user, parent: :user do
  end

  factory :admin_user, parent: :user do
    role { 'admin' }
  end

  factory :user_with_id, class: 'User' do
    username { Faker::Internet.unique.user_name(specifier: 5).tr('.', '') }
    email { generate(:user_email) }
    default_network_id { 79 }
    confirmed_at { Time.current }
    id { Faker::Number.unique.between(from: 1, to: 10_000) }
  end
end
