class AddCrdNumberToBusiness < ActiveRecord::Migration[5.2]
  def change
    add_column :business, :crd_number, :integer
    add_index :business, :crd_number, unique: true
  end
end
