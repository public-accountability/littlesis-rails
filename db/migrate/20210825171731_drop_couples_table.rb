class DropCouplesTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :couples
  end
end
