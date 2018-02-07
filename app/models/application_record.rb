class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # This method updates the timestampes AND the last_user_id field
  # If the model does not have the field 'last_user_id'
  # it will delgate to `touch` without raising an error.
  def touch_by(user_or_id)
    new_last_user_id = User.derive_last_user_id_from(user_or_id)
    if has_attribute?(:last_user_id) && (last_user_id != new_last_user_id)
      update(last_user_id: new_last_user_id)
    else
      touch # rubocop:disable Rails/SkipsModelValidations
    end
  end

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
