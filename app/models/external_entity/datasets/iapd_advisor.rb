# frozen_string_literal: true

class ExternalEntity
  module Datasets
    module IapdAdvisor
      def match_action
        entity.add_tag('iapd')

        if (aum = external_data.data['latest_aum'])
          if entity.has_extension?('Business')
            entity.business.update!(aum: aum)
          else
            entity.add_extension('Business', aum: aum)
          end
        end

        crd_number = external_data.dataset_id

        if ExternalLink.crd_number?(crd_number)
          ExternalLink.crd.find_or_create_by!(entity_id: entity_id, link_id: crd_number)
        end
      end

      def add_reference
        if ExternalLink.crd_number?(external_data.dataset_id)
          entity.add_reference(url: "https://adviserinfo.sec.gov/Firm/#{external_data.dataset_id}",
                               name: "Investment Adviser Public Disclosure: #{external_data.dataset_id}")
            .save!
        end
      end

      def matches
        # TODO: handle additional aliases
        org_name = external_data.data['names'].first
        EntityMatcher.find_matches_for_org(org_name)
      end

      def search_for_matches(search_term)
        EntityMatcher.find_matches_for_org(search_term)
      end

      def automatch
        unless matched?
          if ExternalLink.crd_number?(external_data.dataset_id)
            if (external_link = ExternalLink.crd.find_by(link_id: external_data.dataset_id))
              match_with(external_link.entity)
            end
          end
        end
        self
      end

      protected

      def set_primary_ext
        self.primary_ext = 'Org'
      end
    end
  end
end
