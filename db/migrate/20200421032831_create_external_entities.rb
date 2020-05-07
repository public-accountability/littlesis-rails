class CreateExternalEntities < ActiveRecord::Migration[6.0]
  def change
    create_table :external_entities do |t|
      t.integer :dataset, :limit => 1, :null => false
      t.text :match_data, :size => :long
      t.references :external_data, :index => true
      t.references :entity, :index => true

      t.timestamps
    end
  end
end
