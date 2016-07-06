FactoryGirl.define do
  factory :sf_user_two, class: SfGuardUser do
    id 2
    username 'sfusertwo'
  end

  factory :user_two, class: User do
    id 2
    username 'usertwo'
    sf_guard_user_id 2
  end
  
  factory :list, class: List do
    name "Fortune 1000 Companies"
    description "Fortune Magazine's list..."
    is_ranked true
    is_admin false
    is_featured false
    is_network false
  end
  
  factory :mega_corp_inc, class: Entity do
    name "mega corp INC"
    primary_ext "Org"
    last_user_id 1
  end

  factory :mega_corp_llc, class: Entity do
    name "mega corp LLC"
    primary_ext "Org"
  end

  factory :image, class: Image do
    filename 'image.jpg'
    title '#corporateSelfie'
  end

  factory :group, class: Group do
    name 'a team'
    slug '/'
  end
  
  factory :note, class: Note do
    user_id 1
    body 'why is EVERYTHING connected?'
    body_raw 'why is EVERYTHING connected?'
  end
end
