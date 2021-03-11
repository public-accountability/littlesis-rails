class CreateFECMatch < ActiveRecord::Migration[6.1]
  def change
    create_table :fec_matches do |t|
      t.bigint :sub_id, null: false
      t.bigint :donor_id, null: false
      t.bigint :recipient_id
      t.bigint :candidate_id

      t.timestamps
    end
  end
end
