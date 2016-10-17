class CreateNyFilers < ActiveRecord::Migration
  def change
    create_table :ny_filers do |t|
      t.string :filer_id, null: false
      t.string :name
      t.string :filer_type
      t.string :status
      t.string :committee_type
      t.integer :office
      t.integer :district
      t.string :treas_first_name
      t.string :treas_last_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.timestamps
    end
    add_index :ny_filers, :filer_id, :unique => true
    add_index :ny_filers, :filer_type
  end
end
