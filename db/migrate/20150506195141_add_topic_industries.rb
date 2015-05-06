class AddTopicIndustries < ActiveRecord::Migration
  def change
    create_table :industries do |t|
      t.string :name, null: false
      t.string :industry_id, null: false
      t.string :sector_name, null: false
      t.index :industry_id, unique: true
    end

    create_table :topic_industries do |t|
      t.references :topic
      t.references :industry
      t.index [:topic_id, :industry_id], unique: true
    end
  end
end
