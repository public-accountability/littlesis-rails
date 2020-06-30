# frozen_string_literal: true

# A NyFiler is a committee or PAC registered with the NYS board of elections
# Committee types
#  1      Individual campaign committee
#  2      PAC
#  3-7    Constituted/Party Committee
#  3H-7H  Constituted/party campaign finance registration form
#  8      Independent Expenditure Committee (unauthorized)
#  9      Authorized Multi-Candidate Committees
#  9B     Ballot Issue Committee
# Source: https://www.elections.ny.gov/NYSBOE/download/finance/hndbk2019.pdf
# Forms: https://www.elections.ny.gov/CampaignFinanceForms.html
class ExternalEntity
  module Datasets
    module NYSFiler
      def matches
        if external_data.wrapper.individual_campaign_committee?
          EntityMatcher.find_matches_for_person(
            EntityMatcher::NyFiler.extract_name_from(external_data.wrapper.name)
          )
        else
          EntityMatcher.find_matches_for_org(external_data.wrapper.name)
        end
      end

      def search_for_matches(search_term)
        if external_data.wrapper.individual_campaign_committee?
          EntityMatcher.find_matches_for_person(search_term)
        else
          EntityMatcher.find_matches_for_org(search_term)
        end
      end

      def match_action
        filer_id = external_data.dataset_id
        ExternalLink
          .nys_filer
          .find_or_create_by!(entity_id: entity_id, link_id: filer_id)
      end

      # Filer type #1 is an "Individual Campaign Committee"
      # and is associated directly with the politician or candidate.
      # PACs and other committees are matched with Organizations.
      def set_primary_ext
        self.primary_ext = if external_data.wrapper.individual_campaign_committee?
                             'Person'
                           else
                             'Org'
                           end
      end
    end
  end
end
