class CreateCouple < ActiveRecord::Migration
  def change
    create_table :couple do |t|
      t.integer :entity_id, null: false
      t.integer :partner1_id
      t.integer :partner2_id
    end

    add_index :couple, :entity_id
    add_index :couple, :partner1_id
    add_index :couple, :partner2_id
  end
end
