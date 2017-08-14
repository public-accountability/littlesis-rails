module Tagable
  def tag(name_or_id)
    Tagging.find_or_create_by(tag_id:         Tag.find!(name_or_id)[:id],
                              tagable_class:  self.class.name,
                              tagable_id:     self.id)
  end
  
  def tags
    taggings.map { |tagging| Tag.find(tagging.tag_id) }
  end

  def taggings
    Tagging.where(tagable_id: self.id, tagable_class: self.class.name)
  end
    
end
