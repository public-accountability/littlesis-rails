# fields:bioguide_id, govtrack_id, crp_id, pvs_id, watchdog_id, entity_id
class ElectedRepresentative < ApplicationRecord
  include SingularTable

  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :elected_representative
end
