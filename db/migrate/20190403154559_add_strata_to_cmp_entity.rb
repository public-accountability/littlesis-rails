class AddStrataToCmpEntity < ActiveRecord::Migration[5.2]
  def change
    add_column :cmp_entities, :strata, :tinyint, unsigned: true
  end
end
