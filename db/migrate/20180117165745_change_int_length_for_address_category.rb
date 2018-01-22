class ChangeIntLengthForAddressCategory < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :address, :address_category
    change_column :address, :category_id, :int, limit: 4
    change_column :address_category, :id, :int, limit: 4
    add_foreign_key :address, :address_category, column: "category_id", on_update: :cascade, on_delete: :nullify
  end
end
