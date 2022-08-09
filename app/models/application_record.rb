# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  attr_accessor :current_user

  # This works just like `attribute=` except that
  # it will not assign the value if the attribute
  # already has a non-balnk value.  This is useful
  # to update models without overwriting existing data.
  #
  # @param attribute [String, Symbol] attribute name
  # @param value [Any] what value to assign
  def assign_attribute_unless_present(attribute, value)
    if respond_to?("#{attribute}=")
      public_send("#{attribute}=", value) if public_send(attribute).blank?
    else
      raise ActiveRecord::UnknownAttributeError.new(self, attribute)
    end
  end

  def touch_by_current_user
    if current_user.present?
      touch_by current_user
    else
      touch_by User.system_user_id
    end
  end

  # This method updates the timestampes AND the last_user_id field
  # If the model does not have the field 'last_user_id'
  # it will delgate to `touch` without raising an error.
  def touch_by(user_or_id)
    new_last_user_id = User.derive_last_user_id_from(user_or_id, allow_invalid: true)
    if has_attribute?(:last_user_id) && (last_user_id != new_last_user_id)
      update(last_user_id: new_last_user_id)
    else
      touch
    end
  end

  def saved_change_to_any_attribute?(*args)
    until args.length.zero?
      return true if saved_change_to_attribute?(args.shift)
    end
    false
  end

  # shortcut for `attributes.values.to_csv`
  def to_csv
    attributes.values.to_csv
  end

  def self.random
    order('random()').take
  end

  # Takes an array of ids and generates a lookup hash where the
  # ActiveReocrd id is the key and the value is the ActiveRecord object.
  # If ignore is set to true,  `where` is used instead of `find`, suppressing
  # the RecordNotFound error.
  # @param ids [Array<Integer>] models database ids
  # @param ignore [Boolean] ignore missing ids
  def self.lookup_table_for(ids, ignore: false)
    query = ignore ? where(id: ids) : find(ids)
    query.reduce({}) { |acc, x| acc.merge(x.id => x) }
  end

  # Executes the sql statement and returns a single value
  # Assumes the SQL will return a single value i.e. COUNT() queries.
  # example:
  #   execute_one('SELECT COUNT(*) from versions') => 100
  def self.execute_one(sql)
    connection.exec_query(sql).rows.first.first
  end

  # shortcut for running `.connection.exec_query`
  def self.execute_sql(...)
    connection.exec_query(...)
  end

  def self.sqlize_array(arr)
    "('#{arr.join("','")}')"
  end

  # Connection URL for postgres as understood by rails
  def self.psql_connection_string
    dbconfig = Rails.configuration.database_configuration.fetch(Rails.env)
    "postgresql://#{dbconfig['username']}:#{dbconfig['password']}@#{dbconfig['host']}/#{dbconfig['database']}"
  end

  protected

  def set_last_user_id
    self.last_user_id = User.system_user_id unless self.last_user_id.present?
  end
end
