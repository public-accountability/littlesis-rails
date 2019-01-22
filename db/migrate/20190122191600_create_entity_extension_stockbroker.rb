class CreateEntityExtensionStockbroker < ActiveRecord::Migration[5.2]
  def up
    ExtensionDefinition
      .create!({
                 name: "Stockbroker",
                 display_name: "Stockbroker",
                 has_fields: true,
                 parent_id: nil,
                 tier: 2,
                 id: 41
               })
  end

  def down
    ExtensionDefinition.find(41).delete
  end
end
