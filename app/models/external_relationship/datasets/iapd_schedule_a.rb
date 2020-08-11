# frozen_string_literal: true

class ExternalRelationship
  module Datasets
    module IapdScheduleA
      def relationship_attributes
        attrs = { position_attributes: {} }
        attrs[:start_date] = external_data.wrapper.min_acquired.to_s
        attrs[:description1] = external_data.wrapper.last_record['title_or_status']
        attrs[:is_current] = true if external_data.wrapper.last_record['iapd_year'] >= '2019'

        if Position.description_indicates_board_membership(attrs[:description1])
          attrs[:position_attributes][:is_board] = true
        end

        if Position.description_indicates_executive(attrs[:description1])
          attrs[:position_attributes][:is_executive] = true
        end

        attrs
      end

      def potential_matches_entity1(search_term = nil)
        name = search_term.presence || external_data.wrapper.last_record['name']

        if external_data.wrapper.last_record['owner_type'] == 'I' # person
          EntityMatcher.find_matches_for_person(name)
        else
          EntityMatcher.find_matches_for_org(name)
        end
      end

      def potential_matches_entity2(search_term = nil)
        if search_term.present?
          EntityMatcher.find_matches_for_org(search_term)
        else
          ExternalData
            .find_by(dataset_id: external_data.wrapper.advisor_crd_number)
            &.external_entity
            &.matches || []
        end
      end

      def automatch
        return if matched? || entity2_id.present?

        if external_data.wrapper.advisor_crd_number
          if (entity2 = ExternalLink.crd.find_by(link_id: external_data.wrapper.advisor_crd_number))
            update!(entity2_id: entity2.id)
          end
        end
      end

      # --> <Relationship> | nil
      def find_existing
        relationships = Relationship.where(attributes.slice('category_id', 'entity1_id', 'entity2_id')).to_a

        return nil if relationships.empty?

        if relationships.length > 1
          log "Found #{relationship.length} relationships. Selecting existing relationship #{relationships.first.id}"
        end

        relationships.first
      end
    end
  end
end
