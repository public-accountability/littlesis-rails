FactoryGirl.define do
  
  factory :list, class: List do
    name "Fortune 1000 Companies"
    description "Fortune Magazine's list..."
    is_ranked true
    is_admin false
    is_featured false
    is_network false
  end
  
  factory :entity, class: Entity do
    
  end
end
