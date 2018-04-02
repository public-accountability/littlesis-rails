class ChangeImagesEntityIdNullable < ActiveRecord::Migration
  def change
  	change_column_null :image, :entity_id, null: true
  end
end
