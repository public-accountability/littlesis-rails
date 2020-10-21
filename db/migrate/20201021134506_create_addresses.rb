class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.text :street1
      t.text :street2
      t.text :street3
      t.text :city
      t.string :state
      t.string :country
      t.text :normalized_address
      t.references :location, foreign_key: true

      t.timestamps
    end
  end
end
