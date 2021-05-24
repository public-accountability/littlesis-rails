class AddIsFeaturedColumnToRelationships < ActiveRecord::Migration[6.1]
  def change
    add_column :relationship, :is_featured, :boolean, null: false, default: false
    add_index :relationship, :is_featured
  end
end
