class AddSettingsToNetworkMap < ActiveRecord::Migration[6.0]
  def change
    change_table :network_map do |t|
      t.text :settings
    end
  end
end