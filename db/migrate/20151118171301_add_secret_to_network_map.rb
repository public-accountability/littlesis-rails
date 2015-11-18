class AddSecretToNetworkMap < ActiveRecord::Migration
  def change
    change_table :network_map do |t|
      t.string :secret
    end
  end
end
