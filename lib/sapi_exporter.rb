# frozen_string_literal: true

class SapiExporter
  def self.run
    FileUtils.mkdir_p Rails.root.join('data', abbr)
    new(find_linked_entities).run
    new(Tag.find_by_name('anti-gender').entities, 'anti-gender').run
  end

  def initialize(entities, label = nil)
    @entities = entities
    @fname_prefix = label.present? ? "#{label}-" : ''
  end

  def run
    open_file(fname: 'entities', ext: 'json', prefix: @fname_prefix) do |file|
      file.write JSON.pretty_generate(@entities.map(&:api_json))
    end

    open_file(fname: 'entities', ext: 'csv', prefix: @fname_prefix) do |file|
      data = @entities.map do |entity|
        entity.attributes.except('summary', 'notes', 'parent_id', 'is_deleted', 'last_user_id', 'merged_id', 'delta')
      end

      file.write CSV.generate_line(data.first.keys)
      data.each { |h| file.write(CSV.generate_line(h.values)) }
    end

    relationships = @entities.map(&:relationships).flatten.uniq

    open_file(fname: 'relationships', ext: 'json', prefix: @fname_prefix) do |file|
      file.write JSON.pretty_generate(relationships.map { |r| r.api_json(skip_included: true) })
    end

    open_file(fname: 'relationships', ext: 'csv', prefix: @fname_prefix) do |file|
      data = relationships.map do |relationship|
        relationship.attributes.except('is_deleted', 'last_user_id', 'is_featured')
      end

      file.write CSV.generate_line(data.first.keys)
      data.each { |h| file.write(CSV.generate_line(h.values)) }
    end
  end

  private

  def open_file(fname:, ext:, prefix: '', &block)
    filename = "#{prefix}#{fname}-#{LsDate.today}.#{ext}"
    File.open(Rails.root.join('data', self.class.abbr, filename), 'w', &block)
  end

  def self.abbr
    name[0, 4].downcase
  end

  def self.find_linked_entities
    Entity.find_by_sql(<<~SQL.squish)
      SELECT entities.*, external_links.link_id as #{abbr.reverse}_id
      FROM external_links
      INNER JOIN entities ON entities.id = external_links.entity_id
      WHERE external_links.link_type = 6 AND entities.is_deleted IS false
    SQL
  end
end
