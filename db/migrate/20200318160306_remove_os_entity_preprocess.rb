class RemoveOsEntityPreprocess < ActiveRecord::Migration[6.0]
  def change
    drop_table :os_entity_preprocess
  end
end
