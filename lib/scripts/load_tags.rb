# usage:
# $ load Rails.root.join('lib', 'scripts', 'load_tags.rb')
# $ LoadTags.load(tag_id: <id>, num_tags: <num>)

module LoadTags
  def self.load(tag_id: 1, num_tags: 10)
    tag = ::Tag.find(tag_id)

    entities = %w[Person Org].map do |entity_type|
      ::Entity.where(primary_ext: entity_type).limit(num_tags)
    end.flatten
    lists = ::List.first(num_tags)
    relationships = ::Relationship.first(num_tags)

    (entities + lists + relationships).each do |tagable|
      tagable.tag(tag.id)
    end
  end
end
