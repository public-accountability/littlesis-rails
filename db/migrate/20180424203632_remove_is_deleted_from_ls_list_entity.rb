class RemoveIsDeletedFromLsListEntity < ActiveRecord::Migration[5.1]
  #
  # run this before:
  #   ListEntity.unscoped.where(is_deleted: true).delete_all
  #
  def change
    remove_index :ls_list_entity, name: "entity_deleted_list_idx"
    remove_index :ls_list_entity, name: "list_deleted_entity_idx"
    remove_column :ls_list_entity, :is_deleted
    add_index :ls_list_entity, [:entity_id, :list_id]
  end
end
