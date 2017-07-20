FactoryGirl.define do
  factory :list, class: List do
    name "Fortune 1000 Companies"
    description "Fortune Magazine's list..."
    is_ranked true
    is_admin false
    is_featured false
    is_network false
  end

  factory :list_entity, class: ListEntity do
    sequence(:id)
    sequence(:list_id)
    sequence(:entity_id)
    is_deleted false
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
