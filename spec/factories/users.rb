FactoryBot.define do
  sequence :user_email do |n|
    "user_#{n}@littlesis.org"
  end

  factory :user, class: User do
    username { Faker::Internet.unique.user_name(5).tr('.', '') }
    email { Faker::Internet.unique.email }
    about_me { Faker::Movie.quote }
    default_network_id { 79 }
    confirmed_at { 1.hour.ago }
  end

  # sub-factory pattern. see: https://devhints.io/factory_bot
  factory :really_basic_user, parent: :user do
    association :sf_guard_user, factory: :sf_user
  end

  factory :admin_user, parent: :user do
    association :sf_guard_user, factory: :admin_sf_user
  end

  factory :basic_sf_user, parent: :sf_user do
    after :create do |sf_user|
      SfGuardUserPermission.create!(permission_id: 2, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
    end
  end

  factory :admin_sf_user, parent: :sf_user do
    after :create do |sf_user|
      SfGuardUserPermission.create!(permission_id: 1, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 3, user_id: sf_user.id)
      SfGuardUserPermission.create!(permission_id: 6, user_id: sf_user.id)
    end
  end

  factory :user_with_id, class: User do
    username { Faker::Internet.unique.user_name }
    email { generate(:user_email) }
    default_network_id { 79 }
    confirmed_at { Time.current }
    id { Faker::Number.unique.between(1, 10_000) }
    sf_id = Faker::Number.unique.between(1, 10_000)
    sf_guard_user_id { sf_id }
    association :sf_guard_user, factory: :sf_user, strategy: :build, id: sf_id
  end

  factory :sf_user, class: SfGuardUser do
    is_active { true }
    username { Faker::Internet.unique.user_name }
  end

  factory :sf_guard_user, class: SfGuardUser do
    username { Faker::Internet.unique.user_name }
  end

  factory :admin, class: User do
    id { 200 }
    username { 'admin' }
    email { 'admin@littlesis.org' }
    sf_guard_user_id { 200 }
  end
end
