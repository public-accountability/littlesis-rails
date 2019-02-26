class CreateExternalDatasets < ActiveRecord::Migration[5.2]
  def change
    create_table :external_datasets do |t|
      t.string :name, index: true, null: false
      t.longtext :row_data
      t.boolean :matched, default: false, null: false
      t.longtext :match_data

      t.timestamps
    end
  end
end
