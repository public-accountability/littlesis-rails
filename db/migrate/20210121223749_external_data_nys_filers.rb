class ExternalDataNYSFilers < ActiveRecord::Migration[6.1]
  def change
    create_table(:external_data_nys_filers) do |t|
      t.bigint :filer_id, null: false
      t.string :filer_name
      t.string :compliance_type_desc
      t.string :filter_type_desc
      t.string :filter_status
      t.string :committee_type_desc
      t.string :office_desc
      t.string :district
      t.string :county_desc
      t.string :municipality_subdivision_desc
      t.string :treasurer_first_name
      t.string :treasurer_middle_name
      t.string :treasurer_last_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zipcode

      t.index :filer_name, type: :fulltext
      t.index :filer_id, unique: true
    end
  end
end
