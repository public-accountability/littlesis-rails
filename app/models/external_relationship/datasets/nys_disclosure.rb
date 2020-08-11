# frozen_string_literal: true

class ExternalRelationship
  module Datasets
    module NYSDisclosure
      # def relationship_attributes
      # end

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

      # def find_existing
      # end
    end
  end
end
