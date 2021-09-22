class UseGeneratedColumnForFECContributionsNameTsvector < ActiveRecord::Migration[6.1]
  def up
    remove_index :external_data_fec_contributions, :name_tsvector
    remove_column :external_data_fec_contributions, :name_tsvector

    execute <<~SQL
      ALTER TABLE external_data_fec_contributions
      ADD COLUMN name_tsvector tsvector GENERATED ALWAYS AS (to_tsvector('english', name)) STORED
    SQL

    add_index :external_data_fec_contributions, :name_tsvector, using: "gin"
  end


  def down
    remove_index :external_data_fec_contributions, :name_tsvector
    remove_column :external_data_fec_contributions, :name_tsvector
    add_column :external_data_fec_contributions, :name_tsvector, :tsvector
    add_index :external_data_fec_contributions, :name_tsvector, using: "gin"
  end
end
