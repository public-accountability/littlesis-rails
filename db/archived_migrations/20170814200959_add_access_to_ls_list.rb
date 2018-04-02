class AddAccessToLsList < ActiveRecord::Migration
  def change
    add_column :ls_list, :access, :int1, limit: 1, default: 0, null: false
  end
end
