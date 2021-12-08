class RemoveHasSquareFromImages < ActiveRecord::Migration[6.1]
  def change
    remove_column :images, :has_square
  end
end
