class FlattenAddress < ActiveRecord::Migration
  def up
    add_column :address, :country_name, :string, limit: 50, null: false
    add_column :address, :state_name, :string, limit: 50
    change_column :address, :postal, :string, limit: 20
    remove_foreign_key "address", name: "address_ibfk_1"
    remove_foreign_key "address", name: "address_ibfk_3"
    change_column :address, :state_id, :integer, null: true
    change_column :address, :country_id, :integer, null: true, default: nil
    change_column :address, :street1, :string, limit: 100, null: true
  end

  def down
    remove_column :address, :country_name
    remove_column :address, :state_name
    change_column :address, :postal, :string, limit: 5
    change_column :address, :state_id, :integer, limit: 8, null: false
    change_column :address, :country_id, :integer, limit: 8, default: 1, null: false
    change_column :address, :street1, :string, limit: 100, null: false
    add_foreign_key "address", "address_state", name: "address_ibfk_1", column: "state_id", options: "ON UPDATE CASCADE"
    add_foreign_key "address", "address_country", name: "address_ibfk_3", column: "country_id", options: "ON UPDATE CASCADE"
  end
end
