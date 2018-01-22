class CreateGovernmentAdvisoryAndResearchInstituteEnityExtensions < ActiveRecord::Migration[5.0]
  def up
    ExtensionDefinition.create!([
                                  {name: "ResearchInstitute", display_name: "Academic Research Institute", has_fields: false, parent_id: 2, tier: 3, id: 38},
                                  {name: "GovernmentAdvisoryBody", display_name: "Government Advisory Body", has_fields: false, parent_id: 2, tier: 3, id: 39}
                                ])
  end

  def down
    ExtensionDefinition.find(38).delete
    ExtensionDefinition.find(39).delete
  end
end
