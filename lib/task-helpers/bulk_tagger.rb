require 'csv'

class BulkTagger
  def initialize(filename, mode)
    raise ArgumentError, "Unknown mode: #{mode}" unless [:entity, :list].include?(mode)
    @mode = mode
    @csv_string = File.open(filename).read
  end

  def run
    CSV.parse(@csv_string, headers: true) do |row|
      if @mode == :entity
        tag_entity(row)
      end
    end                                             
  end

  # input: CSV::Row
  def tag_entity(row)
    entity = Entity.find(entity_id_from(row.field('entity_url')))
    tags = row.field('tags').downcase.split(' ')

    tags.each do |tag_name|
      entity.tag(tag_name)
    end

    if row.field('tag_all_related').present?
      tag_related_entities(entity, tags)
    end

  end

  def tag_related_entities(entity, tags)
    entity.links.map(&:entity2_id).uniq.each do |id|
      other_entity = Entity.find(id)
      tags.each { |t| other_entity.tag(t) }
    end
  end

  private

  def entity_id_from(url)
    %r{\/(org|person|entities)\/([0-9]+)[\/-]}.match(url)[2]
  end
end
