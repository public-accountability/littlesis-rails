class AddRAmendColumnToNYSDisclosures < ActiveRecord::Migration[6.1]
  def change
    add_column :external_data_nys_disclosures, :r_amend, :string, limit: 1
  end
end
