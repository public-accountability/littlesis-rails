class AddMapThePowerToUser < ActiveRecord::Migration
  def change
    add_column :users, :map_the_power, :boolean
  end
end
