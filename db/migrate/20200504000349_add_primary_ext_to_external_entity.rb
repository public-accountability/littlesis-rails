class AddPrimaryExtToExternalEntity < ActiveRecord::Migration[6.0]
  def change
    add_column :external_entities, :primary_ext, :string, :limit => 6
  end
end
