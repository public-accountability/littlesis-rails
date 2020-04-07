FactoryBot.define do
  factory :donation, class: Donation do
  end
end

FactoryBot.define do
  factory :position, class: Position do
    is_board { nil }
    is_executive { nil }
    is_employee { nil }
    compensation { nil }
    boss_id { nil }
    # relationship_id nil
  end
end

FactoryBot.define do
  factory :education, class: Education do
  end
end

FactoryBot.define do
  factory :membership, class: Membership do
  end
end

FactoryBot.define do
  factory :bernie_house_membership, class: 'Membership' do
    elected_term do
      {
        'type' => 'rep',
        'start' => '1991-01-03',
        'end' => '2007-01-03',
        'state' => 'VT',
        'district' => 0,
        'party' => 'Independent',
        'caucus' => 'Democrat',
        'url' => 'http://bernie.house.gov',
        'source' => '@unitedstates'
      }
    end
  end
end

FactoryBot.define do
  factory :ownership, class: Ownership do
  end
end

FactoryBot.define do
  factory :transaction, class: Transaction do
  end
end
