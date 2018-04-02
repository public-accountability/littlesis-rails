class ChangeImageUrlLength < ActiveRecord::Migration
  def up
    change_column :image, :url, :string, limit: 400
  end

  def down
    change_column :image, :url, :string, limit: 200
  end
end
