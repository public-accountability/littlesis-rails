class UpdateNyDisclosuresColumnIntLength < ActiveRecord::Migration
  def change
    change_column :ny_disclosures, :transaction_id, :integer, :limit => 8, :null => false
  end
end
