class CreateCmpRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :cmp_relationships do |t|
      t.string :cmp_affiliation_id, null: false
      t.integer :cmp_org_id, null: false
      t.integer :cmp_person_id, null: false
      t.bigint :relationship_id

      t.index :cmp_affiliation_id, unique: true
    end
  end
end
