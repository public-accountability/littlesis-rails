class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name, :null => false
      t.string :tagline
      t.string :description
      t.string :logo
      t.string :cover

      t.timestamps
    end
  end
end
