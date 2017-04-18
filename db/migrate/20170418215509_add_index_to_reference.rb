class AddIndexToReference < ActiveRecord::Migration
  def change
    add_index :reference, [:object_model, :object_id, :ref_type]
  end
end
