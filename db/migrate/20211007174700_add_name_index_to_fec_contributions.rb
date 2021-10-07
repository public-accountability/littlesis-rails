class AddNameIndexToFECContributions < ActiveRecord::Migration[6.1]
  def change
    add_index :external_data_fec_contributions, :name, where: "fec_year >= 2020"
  end
end
