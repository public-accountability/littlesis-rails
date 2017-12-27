module ParamsHelper
  YES_VALUES = [true, 1, '1', 't', 'T', 'true', 'TRUE', 'True', 'yes', 'Yes', 'YES', 'Y', 'y'].to_set.freeze
  NO_VALUES = [false, 0, '0', '00', 'f', 'F', 'false', 'False', 'FALSE', 'NO', 'no', 'No', 'n'].to_set.freeze

  private_constant :YES_VALUES
  private_constant :NO_VALUES

  protected

  # modifies params to be passed to Relationship.update, Relationship.new, Entity.update
  #  - converts blank_values to nil
  #  - adds last_user_id
  #  - processes start and end dates
  #  - converts money strings into intergers
  def prepare_update_params(update_params)
    params = ActiveSupport::HashWithIndifferentAccess.new(blank_to_nil(update_params))
    params['start_date'] = LsDate.convert(params['start_date']) if params.key?('start_date')
    params['end_date'] = LsDate.convert(params['end_date']) if params.key?('end_date')
    params['last_user_id'] = current_user.sf_guard_user_id
    params['is_current'] = is_current_helper(params['is_current']) if params.key?('is_current')
    params['amount'] = money_to_int(params['amount']) if params.key?('amount')
    parameter_processor(params)
  end

  # override this method to modify the param object before sent to .update
  def parameter_processor(params)
    params
  end

  private

  def money_to_int(money)
    return money if money.is_a?(Integer) || money.nil?
    i = money.tr('$', '').tr(',', '').to_i
    return i if i > 0
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

  def is_current_helper(val)
    if YES_VALUES.include?(val)
      true
    elsif NO_VALUES.include?(val)
      false
    else
      nil
    end
  end

end
