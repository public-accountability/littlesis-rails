class DropExternalKeyAndDomainTables < ActiveRecord::Migration[5.0]
  def up
    drop_table :domain
    drop_table :external_key
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
