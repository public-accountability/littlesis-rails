class CreateCommonNames < ActiveRecord::Migration[5.1]
  def change
    create_table :common_names do |t|
      t.string :name
    end
    add_index :common_names, :name, unique: true
  end
end
