FactoryGirl.define do
  factory :user, class: User do
    sequence(:username) { |n| "user_#{n}" }
    sequence(:email) { |n| "user_#{n}@littlesis.org" }
    default_network_id 79
    confirmed_at { Time.now }
  end

  factory :user_with_id, class: User do
    username 'user'
    email 'user@littlesis.org'
    default_network_id 79
    confirmed_at { Time.now }
    id { rand(1000) }
  end

  factory :sf_user, class: SfGuardUser do
    id 100
    sequence(:username) { |n| "user_#{n}" }
  end

  factory :sf_guard_user, class: SfGuardUser do
    sequence(:username) { |n| "user_#{n}" }
  end

  factory :admin, class: User do
    id 200
    username 'admin'
    email 'admin@littlesis.org'
    sf_guard_user_id 200
  end
end
