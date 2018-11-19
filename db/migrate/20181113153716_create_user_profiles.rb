class CreateUserProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_profiles do |t|
      t.integer :user_id, null: false
      t.string :name_first
      t.string :name_last
      t.string :location
      t.text "reason", limit: 4294967295

      t.timestamps
    end

    add_foreign_key :user_profiles, :users
    add_index :user_profiles, :user_id, unique: true
  end
end
