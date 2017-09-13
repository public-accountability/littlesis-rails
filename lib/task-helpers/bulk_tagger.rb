require 'csv'

class BulkTagger
  def initialize(filename)
    @csv_string = File.open(filename).read
  end

  def run
    CSV.parse(@csv_string, headers: true) { |row| tag_entity(row) }
  end

  # input: CSV::Row
  def tag_entity(row)
    entity = Entity.find(entity_id_from(row.field('entity_url')))
    row.field('tags').split(' ').each do |tag_name|
      entity.tag(tag_name.downcase)
    end
  end

  private

  def entity_id_from(url)
    %r{\/(org|person|entities)\/([0-9]+)[\/-]}.match(url)[2]
  end
end
