class CreateExternalData < ActiveRecord::Migration[6.0]
  def change
    create_table :external_data do |t|
      t.integer :dataset, :limit => 1, :null => false
      t.string :dataset_id, :null => false
      t.text :data, :size => :long, :null => false


      t.timestamps

      t.index [:dataset, :dataset_id], :unique => true
    end
  end
end
