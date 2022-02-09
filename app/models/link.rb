# frozen_string_literal: true

class Link < ApplicationRecord
  belongs_to :relationship, inverse_of: :links
  belongs_to :entity, foreign_key: "entity1_id", inverse_of: :links
  belongs_to :related, class_name: "Entity", foreign_key: "entity2_id", inverse_of: :reverse_links
  has_many :references, through: :relationship
  has_many :chained_links, class_name: "Link", foreign_key: "entity1_id", primary_key: "entity2_id"

  class MismatchedSubcategoryError <  Exceptions::LittleSisError; end

  before_create do
    assign_attributes(subcategory: Subcategory.calculate(self))
  end

  def recalculate_subcategory
    update_column :subcategory, Subcategory.calculate(self)
  end

  # used by ListDatatable
  def self.interlock_hash(links)
    links.reduce({}) do |hash, link|
      hash[link.entity2_id] = hash.fetch(link.entity2_id, []).push(link.entity1_id).uniq
      hash
    end
  end

  def self.calculate_subcategory!
    all.includes(:relationship).find_each do |link|
      link.recalculate_subcategory
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

  def <=>(other)
    raise MismatchedSubcategoryError unless subcategory == other.subcategory

    if (featured_compared = Sorting.by_featured(self, other))
      return featured_compared
    end

    if %w[campaign_contributions campaign_contributors donors donations transactions].include?(subcategory)
      amount_compared = Sorting.by_amount(self, other)

      return amount_compared if amount_compared
    end

    if %w[parents children owners holdings].include?(subcategory)
      is_current_compared = Sorting.by_is_current(self, other)

      return is_current_compared if is_current_compared
    end

    if %w[board_members board_memberships businesses offices staff governments positions].include?(subcategory)
      is_current_compared = Sorting.by_is_current(self, other)

      return is_current_compared if is_current_compared

      startdate_compared = Sorting.by_startdate(self, other)

      return startdate_compared if startdate_compared
    end

    # fallback to sorting by updated_at
    relationship.updated_at <=> other.relationship.updated_at
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
end
