module ParamsHelper

  protected

  # modifies params to be passed to Relationship.update, Relationship.new, or Entity.update
  #  - converts blank_values to nil
  #  - adds last_user_id
  #  - processes start and end dates
  def prepare_update_params(update_params)
    params = ActiveSupport::HashWithIndifferentAccess.new(blank_to_nil(update_params))
    params['start_date'] = LsDate.convert(params['start_date']) if update_params.key?('start_date')
    params['end_date'] = LsDate.convert(params['end_date']) if update_params.key?('end_date')
    params['last_user_id'] = current_user.sf_guard_user_id
    params['is_current'] = is_current_helper(params['is_current']) if params.key?('is_current')
    parameter_processor(params)
  end

  # override this method to modify the param object before sent to .update
  def parameter_processor(params)
    params
  end

  private

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

  def is_current_helper
  end

end
