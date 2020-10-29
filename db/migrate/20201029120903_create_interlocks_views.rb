class CreateInterlocksViews < ActiveRecord::Migration[6.0]
  def change
    create_view :interlocks_views
  end
end
