# frozen_string_literal: true

module ParamsHelper
  YES_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'True', 'yes', 'Yes', 'YES', 'Y', 'y', 'on', 'ON'].to_set.freeze
  NO_VALUES = [false, 0, '0', '00', 'f', 'F', 'false', 'False', 'FALSE', 'NO', 'N', 'no', 'No', 'n', 'off', 'OFF'].to_set.freeze
  NIL_VALUES = [nil, '', 'NULL', 'null', 'NIL', 'nil'].to_set.freeze

  private_constant :YES_VALUES
  private_constant :NO_VALUES

  def self.prepare_params(params)
    h = blank_to_nil(params.to_h).with_indifferent_access
    h[:start_date] = LsDate.convert(h[:start_date]) if h.key?(:start_date)
    h[:end_date] = LsDate.convert(h[:end_date]) if h.key?(:end_date)
    h[:is_current] = cast_to_boolean(h[:is_current]) if h.key?(:is_current)
    h[:amount] = money_to_int(h[:amount]) if h.key?(:amount)
    h
  end

  def self.cast_to_boolean(value)
    return true if YES_VALUES.include?(value)
    return false if NO_VALUES.include?(value)
    return nil if NIL_VALUES.include?(value)
    ActiveRecord::Type::Boolean.new.deserialize(value)
  end

  def self.money_to_int(money)
    return money if money.is_a?(Integer) || money.nil?

    i = money.tr('$', '').tr(',', '').to_i
    return i if i.positive?

    return nil
  end

  # converts blanks values (.blank?) of a hash to nil
  # works on nested hashes
  def self.blank_to_nil(hash)
    {}.tap do |new_h|
      hash.each do |key, val|
        if val.is_a? Hash
          new_h[key] = blank_to_nil(val)
        else
          new_h[key] = val.presence
        end
      end
    end
  end

  protected

  # modifies params to be passed to Relationship.update, Relationship.new, Entity.update
  #  - converts blank_values to nil
  #  - adds last_user_id
  #  - processes start and end dates
  #  - converts money strings into intergers
  def prepare_params(parameters)
    p = ParamsHelper.prepare_params(parameters)
    p[:last_user_id] = current_user.id
    parameter_processor(p)
  end

  # override this method to modify the param object before sent to .update
  def parameter_processor(params)
    params
  end

  protected

  def cast_to_boolean(value)
    ParamsHelper.cast_to_boolean(value)
  end

  private

  def money_to_int(value)
    ParamsHelper.money_to_int(value)
  end

  def blank_to_nil(hash)
    ParamsHelper.blank_to_nil(hash)
  end
end
