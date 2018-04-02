class AddLinkCountToEntity < ActiveRecord::Migration
  def change
    add_column :entity, :link_count, :integer, limit: 8, default: 0, null: false
  end
end
