# frozen_string_literal: true

# subcategories are how relationships are filtered on the profile pages
# Position (1)     | board_members, board_memberships, staff, offices, governments, businesses, positions
# Eduction (2)     | students, schools
# Membership (3)   | members, memberships
# Family (4)       | family
# Donation (5)     | campaign_contributions, campaign_contributors, donors, donations
# Transaction (6)  | transactions
# Lobbying (7)     | lobbyied_by, lobbies
# Social (8)       | social
# Professional (9) | social
# Ownership (10)   | owners, holdings
# Hierarchy (11)   | parents, children
# Generic (12)     | generic
class Link
  module Subcategory
    SUBCATEGORIES = %i[board_members board_memberships businesses campaign_contributions campaign_contributors children donations donors family generic holdings lobbied_by lobbies members memberships offices owners parents positions schools social staff students transactions].to_set.freeze
    # link --> text
    def self.calculate(link)
      case link.relationship.category_id
      when Relationship::POSITION_CATEGORY
        entity2_types = link.relationship.related.extension_names.to_set
        if link.relationship.is_board
          if link.is_reverse
            if link.relationship.related.person?
              'staff'
            else
              'board_members'
            end
          else
            'board_memberships'
          end
        elsif link.is_reverse
          'staff'
        else
          if entity2_types.include?('Person')
            'offices'
          elsif entity2_types.include?('GovernmentBody')
            'governments'
          elsif entity2_types.include?('Business')
            'businesses'
          else
            'positions'
          end
        end
      when Relationship::EDUCATION_CATEGORY
        if link.is_reverse
          'students'
        else
          'schools'
        end
      when Relationship::MEMBERSHIP_CATEGORY
        if link.is_reverse
          'members'
        else
          'memberships'
        end
      when Relationship::FAMILY_CATEGORY
        'family'
      when Relationship::DONATION_CATEGORY
        fec_relationship = link.relationship.filings.present? && link.relationship.description1 == 'Campaign Contribution'

        if link.is_reverse
          if fec_relationship
            'campaign_contributors'
          else
            'donors'
          end
        else
          if fec_relationship
            'campaign_contributions'
          else
            'donations'
          end
        end
      when Relationship::TRANSACTION_CATEGORY
        'transactions'
      when Relationship::LOBBYING_CATEGORY
        if link.is_reverse
          'lobbied_by'
        else
          'lobbies'
        end
      when Relationship::SOCIAL_CATEGORY, Relationship::PROFESSIONAL_CATEGORY
        'social'
      when Relationship::OWNERSHIP_CATEGORY
        if link.is_reverse
          'owners'
        else
          'holdings'
        end
      when Relationship::HIERARCHY_CATEGORY
        if link.is_reverse
          'children'
        else
          'parents'
        end
      when Relationship::GENERIC_CATEGORY
        'generic'
      end
    end
  end
end
