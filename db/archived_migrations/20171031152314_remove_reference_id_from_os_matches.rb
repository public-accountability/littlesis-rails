class RemoveReferenceIdFromOsMatches < ActiveRecord::Migration
  def change
    remove_column :os_matches, :reference_id, :integer
  end
end
