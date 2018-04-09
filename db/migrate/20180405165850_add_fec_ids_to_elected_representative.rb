class AddFecIdsToElectedRepresentative < ActiveRecord::Migration[5.1]
  def change
    add_column :elected_representative, :fec_ids, :text
  end
end
