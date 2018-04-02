class DropTopicsTable < ActiveRecord::Migration
  def change
    drop_table :topics
    drop_table :topic_maps
    drop_table :topic_lists
    drop_table :topic_industries
  end
end
