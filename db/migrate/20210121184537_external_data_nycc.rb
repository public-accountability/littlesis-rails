class ExternalDataNYCC < ActiveRecord::Migration[6.1]
  def change
    create_table(:external_data_nycc, primary_key: :district) do |t|
      t.integer :personid, null: false, unique: true, limit: 2
      t.text :council_district
      t.text :last_name
      t.text :first_name
      t.text :full_name
      t.text :photo_url
      t.text :twitter
      t.text :email
      t.text :party
      t.text :website
      t.text :gender
      t.text :title
      t.text :district_office
      t.text :legislative_office
    end
  end
end
