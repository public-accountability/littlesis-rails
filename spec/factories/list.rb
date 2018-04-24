FactoryBot.define do
  factory :list, class: List do
    name "Fortune 1000 Companies"
    description "Fortune Magazine's list..."
    is_ranked true
    is_admin false
    is_featured false
  end

  factory :open_list, class: List do
    name "open list"
    description "open list"
    access Permissions::ACCESS_OPEN
    is_admin false
  end

  factory :closed_list, class: List do
    name "closed list"
    description "closed list"
    access Permissions::ACCESS_CLOSED
    is_admin false
  end

  factory :private_list, class: List do
    name "private list"
    description "private list"
    access Permissions::ACCESS_PRIVATE
    is_admin false
  end

  factory :list_entity, class: ListEntity do
    sequence(:id)
    sequence(:list_id)
    sequence(:entity_id)
    is_deleted false
  end

  factory :note, class: Note do
    user_id 1
    body 'why is EVERYTHING connected?'
    body_raw 'why is EVERYTHING connected?'
  end

end
