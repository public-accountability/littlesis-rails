class CreateUnMatchedNyFilersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :unmatched_ny_filers do |t|
      t.bigint :ny_filer_id, null: false
      t.integer :disclosure_count, null: false
    end
    add_index :unmatched_ny_filers, :ny_filer_id, unique: true
    add_index :unmatched_ny_filers, :disclosure_count, order: { disclosure_count: :desc }
  end
end
