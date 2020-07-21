class AddStatus19toCmpRelationships < ActiveRecord::Migration[6.0]
  def change
    add_column :cmp_relationships, :status19, :int1
  end
end
