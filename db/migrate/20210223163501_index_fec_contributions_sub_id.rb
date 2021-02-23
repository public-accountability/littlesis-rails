class IndexFECContributionsSubId < ActiveRecord::Migration[6.1]
  def change
    add_index :external_data_fec_contributions, :sub_id, unique: true
  end
end
