class AddDeltaToNyDisclosure < ActiveRecord::Migration
  def change
    add_column :ny_disclosures, :delta, :boolean, :default => true, :null => false
    add_index  :ny_disclosures, :delta
  end
end
