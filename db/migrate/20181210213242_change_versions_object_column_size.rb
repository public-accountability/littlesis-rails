class ChangeVersionsObjectColumnSize < ActiveRecord::Migration[5.2]
  def change
    change_column :versions, :object, :text, limit: 4294967295
  end
end
