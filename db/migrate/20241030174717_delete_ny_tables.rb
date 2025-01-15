class DeleteNyTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :ny_disclosures
    drop_table :ny_filer_entities
    drop_table :ny_filers
    drop_table :ny_matches
  end
end
