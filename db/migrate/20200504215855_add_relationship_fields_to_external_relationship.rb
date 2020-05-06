class AddRelationshipFieldsToExternalRelationship < ActiveRecord::Migration[6.0]
  def change
    add_column :external_relationships, :entity1_id, :bigint
    add_column :external_relationships, :entity2_id, :bigint
    add_column :external_relationships, :category_id, :smallint, null: false
  end
end
