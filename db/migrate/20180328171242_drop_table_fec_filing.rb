class DropTableFecFiling < ActiveRecord::Migration[5.0]
  def change
    drop_table :fec_filing
  end
end
