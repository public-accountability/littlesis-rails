class RemoveRelationshipAttributesFromExternalRelationship < ActiveRecord::Migration[6.0]
  def change
    remove_column :external_relationships, :relationship_attributes, :text
  end
end
