class CreateOsCandidates < ActiveRecord::Migration
  def change
    create_table :os_candidates do |t|
      t.string :crp_id, null: false
      t.string :name, null: false
      t.string :district
      t.string :party, limit: 1
      t.string :feccandid, null: false
      t.string :year
      
      t.timestamps
    end
    add_index :os_candidates, :crp_id
    add_index :os_candidates, :feccandid
  end
end

