class CreateOsCandidates < ActiveRecord::Migration
  def change
    create_table :os_candidates do |t|
      t.string :cycle, null: false
      t.string :feccandid, null: false
      t.string :crp_id, null: false
      t.string :name
      t.string :party, limit: 1
      t.string :distid_runfor
      t.string :distid_current
      t.boolean :currcand
      t.boolean :cyclecand
      t.string :crpico, limit: 1
      t.string :recipcode, limit: 2
      t.string :nopacs, limit: 1
      
      t.timestamps
    end

    add_index :os_candidates, :crp_id
    add_index :os_candidates, :feccandid
    add_index :os_candidates, [:cycle, :crp_id]
  end
end

