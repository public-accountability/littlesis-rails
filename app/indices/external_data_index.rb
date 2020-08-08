ThinkingSphinx::Index.define(
  :external_data, :name => 'external_data_nys_disclosure', :with => :active_record
) do
  where 'external_data.dataset = 4'

  join external_relationship

  # Is this external relationship matched?
  has 'IF(external_relationships.relationship_id is NULL, FALSE, TRUE)', as: :matched, type: :boolean

  # Attributes from disclosure: transaction_code, date, amount

  has "CAST(JSON_VALUE(external_data.data, '$.TRANSACTION_CODE') AS CHAR(1))", as: :transaction_code, type: :string

  has(<<-SQL, as: :date, type: :string)
    CASE
        WHEN JSON_VALUE(external_data.data, '$.DATE1_10') = '' THEN NULL
        ELSE DATE_FORMAT(STR_TO_DATE(JSON_VALUE(external_data.data, '$.DATE1_10'),  '%m/%d/%Y'), '%Y-%m-%d')
    END
  SQL

  has(<<-SQL, :as => :amount, :type => :bigint)
    CASE
      WHEN JSON_VALUE(external_data.data, '$.AMOUNT_70') = ''  THEN NULL
      ELSE CAST(ROUND(CAST(JSON_VALUE(external_data.data, '$.AMOUNT_70') as FLOAT)) as SIGNED)
    END
  SQL

  indexes <<~SQL
    TRIM(
      CONCAT_WS(' ',
        JSON_VALUE(external_data.data, '$.FIRST_NAME_40'),
        JSON_VALUE(external_data.data, '$.LAST_NAME_44'),
        JSON_VALUE(external_data.data, '$.CORP_30')
      )
    )
  SQL
end
