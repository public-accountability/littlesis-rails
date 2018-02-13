class ExtensionRecord < ApplicationRecord
  include SingularTable
  include Api::Serializable

  has_paper_trail on: [:create, :destroy],
                  unless: proc { |er| [1, 2].include? er.definition_id },
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :extension_records, touch: true
  belongs_to :extension_definition, foreign_key: "definition_id", inverse_of: :extension_records

  # Returns nested array:
  # [ [ count, display_name ] ]
  def self.stats
    sql = <<-SQL
    SELECT subquery.c, display_name
    FROM (
           SELECT definition_id, count(*) as c
           FROM extension_record
           INNER JOIN entity ON entity.id = extension_record.entity_id
           WHERE entity.is_deleted = 0
           GROUP BY definition_id
         ) as subquery
     INNER JOIN extension_definition ON subquery.definition_id = extension_definition.id
     ORDER BY subquery.c desc
     SQL
    ApplicationRecord.connection.execute(sql).to_a
  end

  # Returns nested array
  # [ [ count, display name] ]
  def self.data_summary
    Rails.cache.fetch('data_summary_stats', expires_in: 2.hours) do
      ExtensionRecord.stats.unshift([Reference.count, 'Citation'], [Relationship.count, 'Relationship'])
    end
  end
end
