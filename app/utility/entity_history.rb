# Class used to retrive information abou
# historic changes changes to an entity
class EntityHistory
  attr_internal :entity

  def initialize(entity_or_id)
    self.entity = Entity.entity_for(entity_or_id)
  end

  def versions
    entity.versions.order('created_at DESC')
  end
end
