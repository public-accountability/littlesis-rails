class AddColorToDashboardBulletin < ActiveRecord::Migration[5.2]
  def change
    add_column :dashboard_bulletins, :color, :string
  end
end
