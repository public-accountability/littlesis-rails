FactoryGirl.define do
  sequence :entity_id do |n|
    n
  end

  factory :org, class: Entity do
    name 'org'
    primary_ext 'Org'
    id { generate(:entity_id) }
  end

  factory :elected, class: Entity do
    name 'Elected Representative'
    primary_ext 'Person'
    id { generate(:entity_id) }
  end

  factory :person, class: Entity do
    name 'Human Being'
    primary_ext 'Person'
    id { generate(:entity_id) }
  end

  factory :corp, class: Entity do
    name 'corp'
    primary_ext 'Org'
    id { generate(:entity_id) }
  end

  factory :mega_corp_inc, class: Entity do
    name 'mega corp INC'
    blurb 'mega corp is having an existential crisis'
    primary_ext 'Org'
    last_user_id 1
    id { generate(:entity_id) }
  end

  factory :mega_corp_llc, class: Entity do
    name 'mega corp LLC'
    primary_ext 'Org'
    id { generate(:entity_id) }
  end

  factory :us_house, class: Entity do
    name 'U.S. House'
    primary_ext 'Org'
    id 12884
  end

  factory :pac, class: Entity do
    name 'PAC'
    blurb 'Ruining our democracy one dollar at a time'
    primary_ext 'Org'
    id { generate(:entity_id) }
  end
end
