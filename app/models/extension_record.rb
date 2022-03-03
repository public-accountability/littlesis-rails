# frozen_string_literal: true

class ExtensionRecord < ApplicationRecord
  include Api::Serializable

  has_paper_trail on: [:create, :destroy],
                  unless: proc { |er| [1, 2].include? er.definition_id },
                  meta: { entity1_id: :entity_id },
                  versions: { class_name: 'ApplicationVersion' }

  belongs_to :entity, inverse_of: :extension_records, touch: true, optional: true
  belongs_to :extension_definition, foreign_key: 'definition_id', inverse_of: :extension_records

  # Returns nested array:
  # [ [ count, display_name ] ]
  def self.stats
    ApplicationRecord.connection.exec_query(<<~SQL.squish).to_a.map(&:values)
      SELECT subquery.c, display_name
      FROM (
           SELECT definition_id, count(*) as c
           FROM extension_records
           INNER JOIN entities ON entities.id = extension_records.entity_id
           WHERE entities.is_deleted is false
           GROUP BY definition_id
         ) as subquery
       INNER JOIN extension_definitions ON subquery.definition_id = extension_definitions.id
       ORDER BY subquery.c desc
    SQL
  end

  # Returns nested array
  # [ [ count, display name] ]
  def self.data_summary
    Rails.cache.fetch('data_summary_stats', expires_in: 2.hours) do
      ExtensionRecord.stats.unshift([Reference.count, 'Citation'], [Relationship.count, 'Relationship'])
    end
  end
end
