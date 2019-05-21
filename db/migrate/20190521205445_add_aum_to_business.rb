class AddAumToBusiness < ActiveRecord::Migration[5.2]
  def change
    add_column :business, :aum, :bigint
  end
end
