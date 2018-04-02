class AddImageAddress < ActiveRecord::Migration
  def change
    change_table :image do |t|
      t.references :address
      t.string :raw_address, limit: 200
    end

    add_index :image, :address_id
  end
end
