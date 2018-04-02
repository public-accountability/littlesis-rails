class ChangeListNameIndex < ActiveRecord::Migration
  def up
    remove_index :ls_list, name: "uniqueness_idx"
    add_index :ls_list, [:name]
  end

  def down
    remove_index :list_list, column: :name
    add_index :ls_list, [:name], name: "uniqueness_idx", unique: true
  end
end
