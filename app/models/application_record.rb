class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.lookup_table_for(ids)
    find(ids).reduce({}) { |acc, x| acc.merge(x.id => x) }
  end

  # Executes the sql statement and returns a single value
  # Assumes the SQL will return a single value i.e. COUNT() queries.
  # example:
  #   execute_one('SELECT COUNT(*) from versions') => 100
  def self.execute_one(sql)
    connection.execute(sql).first.first
  end
end
