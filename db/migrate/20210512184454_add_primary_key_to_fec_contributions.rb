class AddPrimaryKeyToFECContributions < ActiveRecord::Migration[6.1]
  def up
    execute 'ALTER TABLE external_data_fec_contributions ADD COLUMN id SERIAL PRIMARY KEY'
  end
end
