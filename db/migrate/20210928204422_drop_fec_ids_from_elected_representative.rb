class DropFECIdsFromElectedRepresentative < ActiveRecord::Migration[6.1]
  def change
    remove_column :elected_representatives, :fec_ids
  end
end
