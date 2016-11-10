FactoryGirl.define do
  
  factory :sf_guard_user_profile, class: SfGuardUserProfile do
    name_first 'first'
    name_last 'last'
    public_name 'public_name'
    home_network_id 79
    email 'fake_email@fake_email.com'
    reason 'research'
  end
  
end
