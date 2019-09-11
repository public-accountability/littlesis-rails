class RemoveCrdNumberFromBusinessAndBusinessPerson < ActiveRecord::Migration[6.0]
  def change
    remove_column :business, :crd_number
    remove_column :business_person, :crd_number
  end
end
