FactoryBot.define do
  sequence :user_email do |n|
    "user_#{n}@littlesis.org"
  end

  factory :user, class: User do
    username { Faker::Internet.unique.user_name.tr('.', '') }
    email { Faker::Internet.unique.email }
    about_me { Faker::Movie.quote }
    default_network_id 79
    confirmed_at { Time.now }
  end

  factory :user_with_id, class: User do
    username { Faker::Internet.unique.user_name }
    email { generate(:user_email) }
    default_network_id 79
    confirmed_at { Time.now }
    id { rand(1000) }
  end

  factory :sf_user, class: SfGuardUser do
    is_active true
    username { Faker::Internet.unique.user_name }
  end

  factory :sf_guard_user, class: SfGuardUser do
    username { Faker::Internet.unique.user_name }
  end

  factory :admin, class: User do
    id 200
    username 'admin'
    email 'admin@littlesis.org'
    sf_guard_user_id 200
  end
end
