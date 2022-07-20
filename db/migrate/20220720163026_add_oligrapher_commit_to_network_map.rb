class AddOligrapherCommitToNetworkMap < ActiveRecord::Migration[7.0]
  def up
    add_column :network_maps, :oligrapher_commit, :string
    NetworkMap.unscoped.update_all oligrapher_commit: "8befacd0722cbf208b7b5e795e9bfd590d367042"
    change_column_null :network_maps, :oligrapher_commit, false
  end

  def down
    remove_column :network_maps, :oligrapher_commit
  end
end
