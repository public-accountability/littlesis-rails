FactoryGirl.define do
  
  factory :mega_corp_inc, class: Entity do
    name "mega corp INC"
    blurb "mega corp is having an existential crisis"
    primary_ext "Org"
    last_user_id 1
  end

  factory :mega_corp_llc, class: Entity do
    name "mega corp LLC"
    primary_ext "Org"
  end

end
