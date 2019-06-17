ThinkingSphinx::Index.define(
  :external_dataset,
  :name => 'external_dataset_iapd',
  :with => :active_record
) do

  indexes "JSON_VALUE(row_data, '$.name')", as: 'name'

  has "case when JSON_VALUE(row_data, '$.class') = 'IapdDatum::IapdAdvisor' then 'advisor' when JSON_VALUE(row_data, '$.class') = 'IapdDatum::IapdOwner' then 'owner' else '' end", as: 'iapd_type', type: :string
end
