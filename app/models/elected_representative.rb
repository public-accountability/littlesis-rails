# fields:bioguide_id, govtrack_id, crp_id, pvs_id, watchdog_id, entity_id 
class ElectedRepresentative < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :elected_representative
end
