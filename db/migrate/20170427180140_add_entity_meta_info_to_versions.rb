class AddEntityMetaInfoToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :entity1_id, :integer
    add_column :versions, :entity2_id, :integer
    add_index :versions, :entity1_id
    add_index :versions, :entity2_id
  end
end
