class ExternalDataNYSFilers < ActiveRecord::Migration[6.1]
  def change
    create_table(:external_data_nys_filers, id: false) do |t|
      t.string :filer_id, null: false, unqiue: true
      t.text :name
      t.string :filer_type
      t.string :status
      t.string :committee_type
      t.string :office
      t.string :district
      t.text :treas_first_name
      t.text :treas_last_name
      t.text :address
      t.text :city
      t.string :state
      t.string :zip
    end

    execute "ALTER TABLE external_data_nys_filers ADD PRIMARY KEY (filer_id)"
  end
end
