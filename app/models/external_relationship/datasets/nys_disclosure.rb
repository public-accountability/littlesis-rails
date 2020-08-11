# frozen_string_literal: true

class ExternalRelationship
  module Datasets
    module NYSDisclosure
      def relationship_attributes
        {
          donation_attributes: {},
          start_date: external_data.wrapper.date,
          amount: external_data.wrapper.amount
        }
      end

      def potential_matches_entity1(search_term = nil)
        name = search_term.presence || external_data.wrapper.name


        if external_data.wrapper.donor_primary_ext == 'Org'
          EntityMatcher.find_matches_for_org(name)
        else
          EntityMatcher.find_matches_for_person(name)
        end
      end

      def potential_matches_entity2(search_term = nil)
        nys_filer = external_data.wrapper.filer_record

        if search_term.present?
          nys_filer.external_entity.search_for_matches(search_term)
        else
          nys_filer.external_entity.matches
        end
      end

      # def automatch
      # end

      def find_existing
        relationships = Relationship.where(attributes.slice('category_id', 'entity1_id', 'entity2_id')).to_a

        return nil if relationships.empty?

        relationships.each do |r|
          return r if r.external_dataset_name.eql?(dataset)
        end

        relationships.first
      end
    end
  end
end
