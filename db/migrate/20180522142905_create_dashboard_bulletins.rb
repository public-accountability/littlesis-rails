class CreateDashboardBulletins < ActiveRecord::Migration[5.1]
  def change
    create_table :dashboard_bulletins do |t|
      t.text :markdown
      t.string :title

      t.timestamps
    end

    add_index :dashboard_bulletins, :created_at, order: { created_at: :desc }
  end
end
