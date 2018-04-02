class CreateNyFilerEntities < ActiveRecord::Migration
  def change
    create_table :ny_filer_entities do |t|
      t.belongs_to :ny_filer, index: true
      t.belongs_to :entity, index: true
      t.boolean :is_committee
      t.integer :cmte_entity_id  
      t.string :e_year, limit: 4
      t.string :filer_id
      t.string :office
      
      t.timestamps
    end
    add_index :ny_filer_entities, :is_committee
    add_index :ny_filer_entities, :cmte_entity_id
    add_index :ny_filer_entities, :filer_id 
  end
end
