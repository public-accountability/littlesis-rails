class AddMaidenNameToPerson < ActiveRecord::Migration
  def change
    change_table :person do |t|
      t.string :name_maiden, limit: 50
    end
  end
end
