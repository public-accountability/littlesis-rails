class CreateGroupLists < ActiveRecord::Migration
  def change
    create_table :group_lists do |t|
    	t.references :group
    	t.references :list
    end
  end
end
