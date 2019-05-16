require 'csv'

class BulkTagger
  def initialize(filename, mode)
    raise ArgumentError, "Unknown mode: #{mode}" unless %i[entity list].include?(mode)
    @mode = mode
    @csv_string = File.open(filename).read
  end

  def run
    CSV.parse(@csv_string, headers: true) do |row|
      tag_entity(row) if @mode == :entity
      tag_list(row) if @mode == :list
    end
  end

  # input: CSV::Row
  # fields: entity_url, tags, tag_all_related
  def tag_entity(row)
    entity = Entity.find(model_id_from(row.field('entity_url')))
    tags = row_tags(row)

    tags.each { |tag_name| entity.add_tag(tag_name) }
    tag_related_entities(entity, tags) if row.field('tag_all_related').present?
  end

  def tag_related_entities(entity, tags)
    entity.links.map(&:entity2_id).uniq.each do |id|
      other_entity = Entity.find(id)
      tags.each { |t| other_entity.add_tag(t) }
    end
  end

  # input: CSV::Row
  # fields: list_url, tags, tag_all_in_list
  def tag_list(row)
    list = List.find(model_id_from(row.field('list_url')))
    tags = row_tags(row)

    tags.each { |t| list.add_tag(t) }
    tag_all_in_list(list, tags) if row.field('tag_all_in_list').present?
  end

  def tag_all_in_list(list, tags)
    list.entities.each do |entity|
      tags.each { |t| entity.add_tag(t) }
    end
  end

  private

  def model_id_from(url)
    if url.include? '/lists'
      %r{\/lists\/([0-9]+)[\/-]}.match(url)[1]
    else
      %r{\/(org|person|entities)\/([0-9]+)[\/-]}.match(url)[2]
    end
  end

  # CSV::Row -> Array
  def row_tags(row)
    row.field('tags').downcase.split(' ')
  end
end
