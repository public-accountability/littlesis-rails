FactoryGirl.define do

  factory :user, class: User do
    username "user"
    email "user@littlesis.org"
    default_network_id 79
  end

  factory :sf_user, class: SfGuardUser do 
    id 100
    username 'user'
  end
  
  factory :sf_guard_user, class: SfGuardUser do 
    username 'sf_guard_user'
  end

  factory :admin, class: User do
    id 200
    username "admin"
    email "admin@littlesis.org"
    sf_guard_user_id 200
  end

end
