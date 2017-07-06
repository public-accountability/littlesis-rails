class AddShortDescriptionToLists < ActiveRecord::Migration
  def change
  	add_column	:ls_list, :short_description, :string, limit: 255
  end
end
