class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.string :token, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
    add_index :api_tokens, :token, unique: true
    add_index :api_tokens, :user_id, unique: true
  end
end
