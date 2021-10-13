class CreateFeaturedResources < ActiveRecord::Migration[6.1]
  def change
    create_table :featured_resources do |t|
      t.references :entity, foreign_key: true, null: false
      t.text :title, null: false
      t.text :url, null: false

      t.timestamps
    end
  end
end
