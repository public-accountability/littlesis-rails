FactoryGirl.define do

  factory :user, class: User do
    id 100
    username "user"
    email "user@littlesis.org"
    sf_guard_user_id 100
  end

  factory :admin, class: User do
    id 200
    username "admin"
    email "admin@littlesis.org"
    sf_guard_user_id 200
  end

end
