FactoryGirl.define do
  factory :sf_guard_user_profile, class: SfGuardUserProfile do
    name_first 'first'
    name_last 'last'
    is_confirmed true
    sequence(:public_name) { Faker::Name.unique.name }
    home_network_id 79
    email { Faker::Internet.unique.email }
    reason 'doing research'
  end
end
