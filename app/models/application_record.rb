class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.lookup_table_for(ids)
    find(ids).reduce({}) { |acc, x| acc.merge(x.id => x) }
  end
end
