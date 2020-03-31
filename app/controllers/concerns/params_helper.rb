# frozen_string_literal: true

module ParamsHelper
  YES_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'True', 'yes', 'Yes', 'YES', 'Y', 'y'].to_set.freeze
  NO_VALUES = [false, 0, '0', '00', 'f', 'F', 'false', 'False', 'FALSE', 'NO', 'N', 'no', 'No', 'n'].to_set.freeze
  NIL_VALUES = [nil, '', 'NULL', 'null', 'NIL', 'nil'].to_set.freeze

  private_constant :YES_VALUES
  private_constant :NO_VALUES

  protected

  # modifies params to be passed to Relationship.update, Relationship.new, Entity.update
  #  - converts blank_values to nil
  #  - adds last_user_id
  #  - processes start and end dates
  #  - converts money strings into intergers
  def prepare_params(parameters)
    p = ActiveSupport::HashWithIndifferentAccess.new blank_to_nil(parameters.to_h)
    p['start_date'] = LsDate.convert(p['start_date']) if p.key?('start_date')
    p['end_date'] = LsDate.convert(p['end_date']) if p.key?('end_date')
    p['last_user_id'] = current_user.id
    p['is_current'] = cast_to_boolean(p['is_current']) if p.key?('is_current')
    p['amount'] = money_to_int(p['amount']) if p.key?('amount')
    parameter_processor(p)
  end

  # override this method to modify the param object before sent to .update
  def parameter_processor(params)
    params
  end

  protected

  def cast_to_boolean(value)
    return true if YES_VALUES.include?(value)
    return false if NO_VALUES.include?(value)
    return nil if NIL_VALUES.include?(value)
    ActiveRecord::Type::Boolean.new.deserialize(value)
  end

  private

  def money_to_int(money)
    return money if money.is_a?(Integer) || money.nil?
    i = money.tr('$', '').tr(',', '').to_i
    return i if i.positive?
    return nil
  end

  # converts blanks values (.blank?) of a hash to nil
  # works on nested hashes
  def blank_to_nil(hash)
    new_h = {}
    hash.each do |key, val|
      if val.is_a? Hash
        new_h[key] = blank_to_nil(val)
      else
        new_h[key] = val.blank? ? nil : val
      end
    end
    new_h
  end
end
