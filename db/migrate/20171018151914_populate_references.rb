class PopulateReferences < ActiveRecord::Migration
  def self.up
    sql = File.read(Rails.root.join('lib', 'sql', 'populate_references.sql'))
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.down
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE `references`")
  end
end
