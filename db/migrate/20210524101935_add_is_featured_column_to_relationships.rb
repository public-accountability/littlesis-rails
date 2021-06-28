class AddIsFeaturedColumnToRelationships < ActiveRecord::Migration[6.1]
  def change
    add_column :relationships, :is_featured, :boolean, null: false, default: false
    add_index :relationships, :is_featured
  end
end
