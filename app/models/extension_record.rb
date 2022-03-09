# frozen_string_literal: true

class ExtensionRecord < ApplicationRecord
  include Api::Serializable

  has_paper_trail on: [:create, :destroy],
                  unless: proc { |er| [1, 2].include? er.definition_id },
                  meta: { entity1_id: :entity_id },
                  versions: { class_name: 'ApplicationVersion' }

  belongs_to :entity, inverse_of: :extension_records, touch: true, optional: true
  belongs_to :extension_definition, foreign_key: 'definition_id', inverse_of: :extension_records

  # [ [definition_id, count] ]
  def self.stats
    connection.exec_query(<<~SQL.squish).map(&:values)
      SELECT definition_id, count(*) as c
      FROM extension_records
      INNER JOIN entities ON entities.id = extension_records.entity_id
      WHERE entities.is_deleted is false
      GROUP BY definition_id
      ORDER BY c desc
    SQL
  end

  # Returns nested array
  # [ [ count, display name] ]
  def self.data_summary
    Rails.cache.fetch("data_summary_stats_#{I18n.locale}", expires_in: 2.hours) do
      ExtensionRecord.stats
        .map { |definition_id, count| [ ExtensionDefinition::DISPLAY_NAMES.fetch(I18n.locale).fetch(definition_id), count] }
        .unshift([I18n.t('vocab.citations').capitalize, Reference.count], [I18n.t('vocab.relationships').capitalize, Relationship.count])
    end
  end
end
