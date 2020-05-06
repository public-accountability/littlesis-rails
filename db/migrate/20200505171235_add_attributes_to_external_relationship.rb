class AddAttributesToExternalRelationship < ActiveRecord::Migration[6.0]
  def change
    add_column :external_relationships, :relationship_attributes, :text
  end
end
