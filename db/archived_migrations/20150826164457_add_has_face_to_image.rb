class AddHasFaceToImage < ActiveRecord::Migration
  def change
    change_table :image do |t|
      t.boolean :has_face, null: false, default: false
    end
  end
end
