class NyDisclosure < ActiveRecord::Base
  #self.table_name = "d_sample" # FOR TESTING

  has_one :ny_match, inverse_of: :ny_disclosure

  def full_name
    unless first_name.nil? and last_name.nil?
      middle_name = mid_init.nil? ? " " : " #{mid_init} "
      "#{first_name.to_s}#{middle_name}#{last_name.to_s}".titleize
    end
  end
  
  def is_matched
    !ny_match.blank?
  end

end
