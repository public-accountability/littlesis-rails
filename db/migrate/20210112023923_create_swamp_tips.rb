class CreateSwampTips < ActiveRecord::Migration[6.1]
  def change
    create_table :swamp_tips do |t|
      t.text :content

      t.timestamps
    end
  end
end
