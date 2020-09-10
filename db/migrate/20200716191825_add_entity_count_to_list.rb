class AddEntityCountToList < ActiveRecord::Migration[6.0]
  def up
    ActiveRecord::Base.transaction do
      add_column :ls_list, :entity_count, :integer, default: 0

      List.left_joins(:list_entities)
        .group(:id)
        .pluck(:id, 'COUNT(ls_list_entity.id) as count').each do |id, count|
        List.find(id).update_columns(entity_count: count)
      end
    end
  end

  def down
    remove_column :ls_list, :entity_count
  end
end
