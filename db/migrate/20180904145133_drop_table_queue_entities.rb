class DropTableQueueEntities < ActiveRecord::Migration[5.2]
  def change
    drop_table :queue_entities
  end
end
