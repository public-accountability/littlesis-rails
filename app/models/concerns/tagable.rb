module Tagable
  def tag(name_or_id)
    tag_id = name_or_id.is_a?(String) ? Tag.by_name(name_or_id)[:id] : name_or_id
    Tagging.create(tag_id:         tag_id,
                   tagable_class:  self.class.name,
                   tagable_id:     self.id)
  end

  def tags
    taggings.to_a.map{ |t| Tag.all.find{ |_t| _t[:id] == t.tag_id } }
  end

  def taggings
    Tagging.where(tagable_id: self.id, tagable_class: self.class.name)
  end
end
