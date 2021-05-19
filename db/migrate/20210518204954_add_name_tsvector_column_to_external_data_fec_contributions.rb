class AddNameTsvectorColumnToExternalDataFECContributions < ActiveRecord::Migration[6.1]
  def up
    add_column :external_data_fec_contributions, :name_tsvector, :tsvector
    add_index :external_data_fec_contributions, :name_tsvector, using: "gin"

    execute <<~SQL
      UPDATE external_data_fec_contributions
      SET name_tsvector = to_tsvector('english', name)
    SQL
  end

  def down
    remove_index :external_data_fec_contributions, :name_tsvector
    remove_column :external_data_fec_contributions, :name_tsvector
  end
end
