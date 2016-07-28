class Reference < ActiveRecord::Base
  include SingularTable

  has_one :os_match
  has_one :os_donation, :through => :os_match
end
