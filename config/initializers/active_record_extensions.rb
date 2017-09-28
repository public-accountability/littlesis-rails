class ActiveRecord::Base
  def self.lookup_table_for(ids)
    find(ids).reduce({}) { |acc, x| acc.merge(x.id => x) }
  end
end
