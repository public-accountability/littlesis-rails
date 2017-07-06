FactoryGirl.define do
  
  factory :sf_guard_user_profile, class: SfGuardUserProfile do
    name_first 'first'
    name_last 'last'
    is_confirmed true
    sequence(:public_name) { |n| "user_#{n}" }
    home_network_id 79
    sequence(:email) { |n| "user_#{n}@littlesis.org" }
    reason 'research'
  end

end
