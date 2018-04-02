class AddUniqueIndexesToSlugs < ActiveRecord::Migration
  def change
  	add_index :groups, :slug, unique: true
  	add_index :campaigns, :slug, unique: true
  end
end
