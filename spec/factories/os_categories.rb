FactoryBot.define do
  factory :os_category_private_equity, class: OsCategory do
    category_id "F2600"
    category_name "Private Equity & Investment Firms"
    industry_id "F07"
    industry_name "Securities & Investment"
    sector_name "Finance, Insurance & Real Estate"
  end
end

FactoryBot.define do
  factory :os_category_defence, class: OsCategory do
    category_id "D6000"
    category_name "Homeland Security contractors"
    industry_id "D03"
    industry_name "Misc Defense"
    sector_name "Defense"
  end
end
