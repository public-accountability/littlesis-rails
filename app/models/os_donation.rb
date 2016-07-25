class OsDonation < ActiveRecord::Base
  validates_uniqueness_of :fec_cycle_id
end
