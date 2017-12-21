FactoryBot.define do
  sequence :entity_id do |n|
    n + 100
  end

  factory :random_entity, class: Entity do
    sequence(:id)
    sequence(:name) { Faker::Name.unique.name }
    primary_ext ['Org', 'Person'].sample
  end

  factory :org, class: Entity do
    name 'org'
    primary_ext 'Org'
    id { generate(:entity_id) }
  end

  factory :entity_org, class: Entity do
    name 'org'
    primary_ext 'Org'
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

  factory :entity_person, class: Entity do
    name 'Human Being'
    primary_ext 'Person'
  end

  factory :merge_source_person, parent: :entity_person do
    with_person_name
    after :create do |person|
      list = create(:list)
      person.add_extension('BusinessPerson')
      ListEntity.create!(list_id: list.id, entity_id: person.id)
      Relationship.create!(category_id: 1, entity: person, related: create(:entity_org))
    end
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
  end

  trait :with_last_user_id do
    last_user_id APP_CONFIG['system_user_id']
  end

  trait :with_person_name do
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
  end

  trait :with_org_name do
    name { Faker::Company.name }
  end
end
