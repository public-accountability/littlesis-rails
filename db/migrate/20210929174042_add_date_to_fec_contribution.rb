class AddDateToFECContribution < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      ALTER TABLE external_data_fec_contributions
      ADD COLUMN date date GENERATED ALWAYS AS (make_date(substr(transaction_dt, 5, 4)::int, substr(transaction_dt, 1, 2)::int, substr(transaction_dt, 3, 2)::int)) STORED
    SQL
  end

  def down
    remove_column :external_data_fec_contributions, :date
  end
end
