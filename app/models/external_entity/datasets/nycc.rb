# frozen_string_literal:true

class ExternalEntity
  module Datasets
    module NYCC
      def match_action
        ListEntity.find_or_create_by!(list_id: NYCC_LIST_ID, entity_id: entity.id)
      end

      def matches
        name = external_data.data['FullName']
        EntityMatcher.find_matches_for_person(name)
      end

      def search_for_matches(search_term)
        EntityMatcher.find_matches_for_person(search_term)
      end

      protected

      def set_primary_ext
        self.primary_ext = 'Person'
      end
    end
  end
end
