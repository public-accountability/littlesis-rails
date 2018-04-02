class AddIndexesForImprovedRelationshipAndLinkQuerying < ActiveRecord::Migration
  def change
    add_index :link, [:entity1_id, :category_id]
    add_index :link, [:entity1_id, :category_id, :is_reverse]
    add_index :relationship, [:is_deleted, :entity2_id, :category_id, :amount], name: 'index_relationship_is_d_e2_cat_amount'
  end
end
