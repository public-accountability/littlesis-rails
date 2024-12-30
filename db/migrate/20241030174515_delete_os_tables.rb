class DeleteOsTables < ActiveRecord::Migration[7.1]
  def change
    drop_table :os_candidate
    drop_table :os_committee
    drop_table :os_donations
    drop_table :os_entity_donor
    drop_table :os_matches
  end
end
