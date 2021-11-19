class DropOsCategories < ActiveRecord::Migration[6.1]
  def change
    drop_table :os_entity_categories
    drop_table :os_categories
  end
end
