FactoryGirl.define do
  factory :position, class: Position do
    is_board nil
    is_executive nil
    is_employee nil
    compensation nil
    boss_id nil
    # relationship_id nil    
  end
end
