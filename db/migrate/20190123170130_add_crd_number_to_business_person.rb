class AddCrdNumberToBusinessPerson < ActiveRecord::Migration[5.2]
  def change
    add_column :business_person, :crd_number, :integer
    add_index :business_person, :crd_number, unique: true
  end
end
