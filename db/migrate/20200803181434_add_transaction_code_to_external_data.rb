class AddTransactionCodeToExternalData < ActiveRecord::Migration[6.0]
  def change
    change_table :external_data do |t|
      t.virtual :transaction_code,
                type: :string,
                as: "JSON_VALUE(data, '$.TRANSACTION_CODE')",
                stored: false

      t.index :transaction_code
    end
  end
end
