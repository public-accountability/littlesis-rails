class AddRelationshipGte < ActiveRecord::Migration
  def change
    change_table :relationship do |t|
      t.boolean :is_gte, null: false, default: false
    end
  end
end
