class AddColumnHiddenEntitiesToExternalDataFECContributions < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'intarray'

    add_column :external_data_fec_contributions, :hidden_entities, :integer, array: true
    add_index :external_data_fec_contributions, :hidden_entities, using: :gist, opclass: :gist__int_ops
  end
end
