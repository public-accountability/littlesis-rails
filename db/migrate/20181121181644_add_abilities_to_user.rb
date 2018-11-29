class AddAbilitiesToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :abilities, :text
  end
end
