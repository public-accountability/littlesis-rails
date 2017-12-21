class RemoveEntityIndexesFromUserRequets < ActiveRecord::Migration
  def change
    remove_index :user_requests, [:source_id, :dest_id]
  end
end
