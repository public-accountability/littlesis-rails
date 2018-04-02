class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
    	t.string :name
    	t.string :tagline
    	t.string :description
    	t.boolean :is_private
    	t.string :slug
    	t.references :default_network
    	t.references :campaign
      t.timestamps
    end
  end
end
