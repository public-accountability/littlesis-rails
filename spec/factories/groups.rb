FactoryGirl.define do
  factory :group do
    sequence(:id)
    name "Goldman Sachs Investigation"
    tagline "This group is putting together a list detailing the key players at Goldman Sachs and their ties to Washington."
    slug "goldmansachs"
  end
end
