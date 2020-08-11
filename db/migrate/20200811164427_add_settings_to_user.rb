class AddSettingsToUser < ActiveRecord::Migration[6.0]
  def change
    change_table :users do |t|
      t.text :settings
    end
  end
end
