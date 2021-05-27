# frozen_string_literal: true

class Link < ApplicationRecord
  self.primary_key = :id

  belongs_to :relationship, inverse_of: :links
  belongs_to :entity, foreign_key: "entity1_id", inverse_of: :links
  belongs_to :related, class_name: "Entity", foreign_key: "entity2_id", inverse_of: :reverse_links
  has_many :references, through: :relationship
  has_many :chained_links, class_name: "Link", foreign_key: "entity1_id", primary_key: "entity2_id"

  default_scope { where(is_deleted: false) }

  def self.interlock_hash_from_entities(entity_ids)
    interlock_hash(where(entity1_id: entity_ids))
  end

  # used by ListDatatable
  def self.interlock_hash(links)
    links.reduce({}) do |hash, link|
      hash[link.entity2_id] = hash.fetch(link.entity2_id, []).push(link.entity1_id).uniq
      hash
    end
  end

  # Retrives first and second degree relationships
  #
  # Relationships are represented as a simple hash, rather than with the full ActiveRecord objects
  # to save on memory, as we may have a lot of records here.
  #
  # Note: hardcoded limit of 20,000
  #
  # Entity | Array[Entity] | Interger --> [{}]
  def self.relationship_network_for(entities)
    entity_ids = Array.wrap(entities).uniq.map! { |e| Entity.entity_id_for(e) }

    sql = <<~SQL
      SELECT *
      FROM links as degree_one_links
      LEFT JOIN links as degree_two_links
            ON degree_one_links.entity2_id = degree_two_links.entity1_id
        #{sanitize_sql_for_conditions(['WHERE degree_one_links.entity1_id IN (?)', entity_ids])}
      LIMIT 20000
    SQL

    ApplicationRecord.connection.exec_query(sql).map do |h|
      # Un-reverse the entity1/2 positions if this is a reverse link, so that they correspond to the fields of the actual
      # relationship object
      if h.delete('is_reverse') == true
        h['entity1_id'], h['entity2_id'] = h['entity2_id'], h['entity1_id']
      end
      h['id'] = h.delete('relationship_id')
      h
    end
  end

  def position_type
    return 'None' unless category_id == 1

    org_types = related.extension_names

    return 'office' if org_types.include? 'Person'
    return 'government' if org_types.include? 'GovernmentBody'
    return 'business' if org_types.include? 'Business'
    return 'other'
  end

  concerning :Description do
    # The text for the short relationship link that appears on entity profile pages.
    def link_content
      "#{description}#{link_date_range}#{relationship_notes_mark}#{ownership_stake}"
    end

    def description
      relationship_label.label
    end

    private

    def relationship_label
      @relationship_label ||= RelationshipLabel.new(relationship, is_reverse)
    end

    def link_date_range
      " #{relationship_label.display_date_range}" if relationship_label.display_date_range.present?
    end

    def relationship_notes_mark
      relationship.notes.present? ? '*' : ''
    end

    def ownership_stake
      stake = relationship&.ownership&.percent_stake
      "; percent stake: #{stake}%" if stake.present?
    end
  end

  # Tell Rails not to try writing to this model, since it is backed by a view
  def readonly?
    true
  end

  # Refresh the view in a background job
  def self.refresh
    if Rails.env.test?
      refresh_materialized_view
    else
      LinksViewRefreshJob.perform_later
    end
  end

  # Refresh the view, concurrently if it has already been populated
  def self.refresh_materialized_view
    Scenic.database.refresh_materialized_view(table_name, concurrently: populated?, cascade: false)
  end

  def self.populated?
    ActiveRecord::Base.connection.execute(
        <<~SQL
          SELECT relispopulated FROM pg_class WHERE relname = '#{table_name}'
        SQL
      )
      &.first['relispopulated']
  end
end
