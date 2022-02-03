class AddSubcategoryToLink < ActiveRecord::Migration[7.0]
  def change
    add_column :links, :subcategory, :text
    add_index :links, :subcategory
  end
end
