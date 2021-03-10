class EditedEntitiesFiveMinuteIndex < ActiveRecord::Migration[6.1]
  def change
    add_index :edited_entities, "round_five_minutes(created_at)", order: :desc
    add_index :edited_entities, "entity_id"
  end
end
