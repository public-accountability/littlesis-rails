ThinkingSphinx::Index.define(
  :external_data,  :name => 'external_data_nys_disclosure', :with => :active_record
) do
  where 'dataset = 4'
  has "JSON_VALUE(data, '$.TRANSACTION_CODE')", :as => :transaction_code, :type => :string

  has "(CASE WHEN JSON_VALUE(data, '$.DATE1_10') = '' THEN NULL ELSE DATE_FORMAT(STR_TO_DATE(JSON_VALUE(data, '$.DATE1_10'),  '%m/%d/%Y'), '%Y-%m-%d') END)",
      :as => :date, :type => :string

  has(<<-SQL, :as => :amount, :type => :bigint)
    CASE
      WHEN JSON_VALUE(data, '$.AMOUNT_70') = ''  THEN NULL
      ELSE CAST(ROUND(CAST(JSON_VALUE(data, '$.AMOUNT_70') as FLOAT)) as SIGNED)
    END
  SQL

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
