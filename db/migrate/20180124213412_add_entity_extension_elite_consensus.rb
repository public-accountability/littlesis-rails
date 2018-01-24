class AddEntityExtensionEliteConsensus < ActiveRecord::Migration[5.0]
  def up
    ExtensionDefinition.create!([
                                  {name: "EliteConsensus", display_name: "Elite Consensus Group", has_fields: false, parent_id: 2, tier: 3, id: 40}
                                ])
  end

  def down
    ExtensionDefinition.find(40).delete
  end
  
end
