class Reference < ActiveRecord::Base
  include SingularTable
  @@ref_types = {1=>"Generic", 2=>"FEC Filing"}
  
  def ref_types
    @@ref_types
  end
  
  has_one :os_match
  has_one :os_donation, :through => :os_match
end
