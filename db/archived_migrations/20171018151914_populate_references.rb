class PopulateReferences < ActiveRecord::Migration
  def self.up
    sql = File.read(Rails.root.join('lib', 'sql', 'populate_references.sql'))
    ApplicationRecord.connection.execute(sql)
  end

  def self.down
    ApplicationRecord.connection.execute("TRUNCATE TABLE `references`")
  end
end
