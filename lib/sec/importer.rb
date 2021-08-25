# frozen_string_literal: true

module SEC
  class Importer
    attr_reader :entity, :company

    def initialize(entity, db: nil)
      @entity = entity
      @cik = cik_from_entity(@entity)
      @company = SEC::Company.new(@cik, db: db)
    end

    def relationships
      # Roster is a hash where the key = the owner CIK, and the values = [Hash]
      # The Hash contains the data from SEC::ReportingOwner, which are selected
      # fields from SEC form 3/4. See lib/sec/roaster.rb
      @company.roster.map do |(reporting_owner_cik, documents)|
        reporting_owner_entity = find_or_initialize_reporting_owner(reporting_owner_cik, documents)
        relationship_from_documents reporting_owner_entity, documents
      end.flatten
    rescue => e
      Rails.logger.warn "Failed to calculate relationships for #{@entity.name_with_id}"
      raise e
    end

    def relationship_from_documents(reporting_owner_entity, documents)
      # Set these fields from the most recent document
      attributes = {
        entity: reporting_owner_entity,
        related: @entity,
        category_id: ::RelationshipCategory.name_to_id[:position],
        description1: documents.first[:title].presence,
        start_date: documents.first[:date_filed],
        is_current: nil,
        position_attributes: {
          is_board: boolean(documents.first[:is_director]),
          is_executive: boolean(documents.first[:is_executive])
        }
      }

      # If the document is within the past 6 months, mark the relationship "current"
      # If the document is older than 2 years ago, mark the relationship "past"
      # Otherwise, leave the relationship status as unknown
      document_days_ago = (Time.zone.today - Date.parse(documents.first[:date_filed])).to_i

      if document_days_ago < 180
        attributes[:is_current] = true
      elsif document_days_ago > 720
        attributes[:is_current] = false
      end

      # Loop through documents
      # Documents are already sorted in descending order. `documents[0]` is the most recent document.
      # If the document contains different values for Director or Executive, halt the processing.
      # Currently, we're only handling the most recent contiguous relationship.
      documents[1..].each.with_index do |document, i|
        director_status_changed = boolean(document[:is_director]) != attributes[:position_attributes][:is_board]
        execuctive_status_changed = boolean(document[:is_executive]) != attributes[:position_attributes][:is_board]

        if director_status_changed || execuctive_status_changed
          Rails.logger.info <<~INFO
            Stopping processing documents for CIK #{document[:cik]} because the director or executive status changed.
            There are #{documents.slice(i..).count} document not examined.
          INFO
          break
        else
          attributes[:start_date] = document[:date_filed]

          if document[:title].present? && attributes[:title].blank?
            attributes[:title] = document[:title]
          end

          if document[:title].present? && (attributes[:title] != document[:title])
            Rails.logger.debug "Mismatching titles ('#{attributes[:title]}', '#{document[:title]}') found for CIK #{document[:cik]}"
          end
        end
      end

      ::Relationship.new(attributes)
    end

    def find_or_initialize_reporting_owner(cik, documents)
      # Try to find the owner by searching by CIK
      reporting_owner = ExternalLink.find_by_cik(cik)&.entity
      return reporting_owner if reporting_owner

      # If the CIK is not in our system, use the EntityMatcher to search for potential matches
      # Only `automatachable` entities are returned
      name = NameParser.sec_parse(documents.first.fetch('name')).to_s
      matcher = EntityMatcher.find_matches_for_person(name, associated: @entity)
      return matcher.automatch.entity if matcher.automatchable?

      Entity.new(name: name, primary_ext: 'Person')
    end

    private

    def cik_from_entity(entity)
      cik = entity.external_links.sec_link&.link_id

      if cik
        cik.rjust(10, '0')
      else
        raise Exceptions::LittleSisError, 'Entity has no CIK number'
      end
    end

    # TODO: move this to ReportingOwner parsing step?
    def boolean(val)
      if [true, 1, '1'].include?(val)
        return true
      elsif [false, 0, '0'].include?(val)
        return false
      else
        return nil
      end
    end
  end
end
