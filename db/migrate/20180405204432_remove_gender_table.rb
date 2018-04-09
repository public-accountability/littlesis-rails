class RemoveGenderTable < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :person, :gender
    drop_table :gender
  end
end
