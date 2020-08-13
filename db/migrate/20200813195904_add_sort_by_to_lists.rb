class AddSortByToLists < ActiveRecord::Migration[6.0]
  def change
    add_column :ls_list, :sort_by, :string
  end
end
