class AddTopicMaps < ActiveRecord::Migration
  def change
    create_table :topic_maps do |t|
      t.references :topic
      t.references :map
      t.index [:topic_id, :map_id], unique: true
    end
  end
end
