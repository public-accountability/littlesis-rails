class UpdateExternalLinkIndexes < ActiveRecord::Migration[6.0]
  def change
    remove_index :external_links, name: "index_external_links_on_entity_id_and_link_type"
    add_index :external_links, [:link_type, :link_id], unique: true
  end
end
