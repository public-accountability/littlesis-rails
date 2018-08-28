# frozen_string_literal: true

class Link < ApplicationRecord
  include SingularTable

  belongs_to :relationship, inverse_of: :links
  belongs_to :entity, foreign_key: "entity1_id", inverse_of: :links
  belongs_to :related, class_name: "Entity", foreign_key: "entity2_id", inverse_of: :reverse_links
  has_many :references, through: :relationship
  has_many :chained_links, class_name: "Link", foreign_key: "entity1_id", primary_key: "entity2_id"

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
  # Note: hardcoded limit of 20,000
  #
  # Entity | Array[Entity] | Interger --> [{}]
  def self.relationship_network_for(entities)
    entity_ids = Array.wrap(entities).uniq.map! { |e| Entity.entity_id_for(e) }

    if entity_ids.length == 1
      where = sanitize_sql_for_conditions(['WHERE degree_one_links.entity1_id = ?', entity_ids.first])
    else
      where = sanitize_sql_for_conditions(['WHERE degree_one_links.entity1_id IN (?)', entity_ids])
    end

    sql = <<-SQL
    SELECT *
    FROM link as degree_one_links
    LEFT JOIN link as degree_two_links
            ON degree_one_links.entity2_id = degree_two_links.entity1_id
    #{where}
    LIMIT 20000
    SQL

    ApplicationRecord.connection.exec_query(sql).to_hash.map do |h|
      if h['is_reverse'] == 1
        h.slice('relationship_id', 'category_id')
          .merge('entity1_id' => h['entity2_id'], 'entity2_id' => h['entity1_id'])
      else
        h.except('id', 'is_reverse')
      end
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

  def is_pfc_link?
    return false if related == nil
    # definition_id = 11
    related.extension_names.include? 'PoliticalFundraising'
  end

  def description
    RelationshipLabel.new(relationship, is_reverse).label
  end
end
