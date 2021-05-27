class RemoveLinksRelationshipIdIsReverseIdx < ActiveRecord::Migration[6.1]
  def change
    remove_index :links, name: 'links_relationship_id_is_reverse_idx'
  end
end
