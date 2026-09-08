class AddQidToEntity < ActiveRecord::Migration[7.2]
  def change
    add_column :entities, :qid, :text
  end
end
