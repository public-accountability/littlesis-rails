# Class used to retrive versions and edits
# for entities
class EntityHistory
  attr_internal :entity

  def initialize(entity_or_id)
    self.entity = Entity.entity_for(entity_or_id)
  end

  def versions
    entity.versions.reorder('created_at DESC')
  end
end
