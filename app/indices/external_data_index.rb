ThinkingSphinx::Index.define(
  :external_data,  :name => 'external_data_nys_disclosure', :with => :active_record
) do
  where 'dataset = 4'
  has "JSON_VALUE(data, '$.TRANSACTION_CODE')", :as => :transaction_code, :type => :string
  has "FORMAT(STR_TO_DATE(JSON_VALUE(data, '$.DATE1_10'),  '%m/%d/%Y'), '%y-%m-%d')", :as => :date, :type => :string
  has "ROUND(CAST(JSON_VALUE(data, '$.TRANSACTION_CODE') as SIGNED))", :as => :amount, :type => :integer

  indexes <<~SQL
    TRIM(
      CONCAT_WS(' ',
        JSON_VALUE(data, '$.FIRST_NAME_40'),
        JSON_VALUE(data, '$.LAST_NAME_44'),
        JSON_VALUE(data, '$.CORP_30')
      )
    )
  SQL
end
