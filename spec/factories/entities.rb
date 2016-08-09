FactoryGirl.define do
  
  factory :elected, class: Entity do 
    name "Elected Representative"
    primary_ext "Person"
  end


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
  
  factory :us_house, class: Entity do
    name "U.S. House"
    primary_ext "Org"
    id 12884
  end
end
