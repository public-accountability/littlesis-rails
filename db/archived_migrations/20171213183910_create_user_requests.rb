class CreateUserRequests < ActiveRecord::Migration
  def change
    create_table :user_requests do |t|
      t.string :type, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :status, null: false, default: 0 # enum
      t.integer :source_id, null: true
      t.integer :dest_id, null: true

      t.index [:source_id, :dest_id]
      t.timestamps null: false
    end
  end
end
