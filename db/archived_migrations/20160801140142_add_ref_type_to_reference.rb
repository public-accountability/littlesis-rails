class AddRefTypeToReference < ActiveRecord::Migration
  def change
    add_column :reference, :ref_type, :integer, default: 1, null: false
  end
end
