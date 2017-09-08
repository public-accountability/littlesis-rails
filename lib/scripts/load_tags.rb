module LoadTags
  def self.load(tag_id: 1, num_tags: 10)
    tag = ::Tag.find(tag_id)

    entities = ::Entity.first(num_tags)
    lists = ::List.first(num_tags)
    relationships = ::Relationship.first(num_tags)

    (entities + lists + relationships).each do |tagable|
      tagable.tag(tag.id)
    end
  end
end
