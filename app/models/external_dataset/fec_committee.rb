# frozen_string_literal: true

module ExternalDataset
  class FECCommittee < ApplicationRecord
    extend DatasetInterface
    extend FECData
    self.dataset = :fec_committees

    include YearScopes

    has_many :contributions, ->(committee) { where(fec_year: committee.fec_year) },
             class_name: 'ExternalDataset::FECContribution',
             foreign_key: 'cmte_id',
             primary_key: 'cmte_id',
             inverse_of: :fec_committee,
             dependent: nil

    belongs_to :candidate, ->(committee) { where(fec_year: committee.fec_year) },
               class_name: 'ExternalDataset::FECCandidate',
               foreign_key: 'cand_id',
               primary_key: 'cand_id',
               optional: true

    belongs_to :external_link,
               -> { where(link_type: :fec_committee) },
               class_name: 'ExternalLink',
               foreign_key: 'cmte_id',
               primary_key: 'link_id',
               optional: true

    has_one :entity, through: :external_link

    def self.saving_arizona_pac
      y22.find_by(cmte_id: 'C00777185')
    end

    def self.facebook_pac
      y22.find_by(cmte_id: 'C00502906')
    end

    def info
      {
        name: display_name,
        propublica: propublica_url,
        designation: committee_designation,
        type: committee_type[0],
        organization_category: interest_group_category
      }
    end

    def committee_designation
      case cmte_dsgn
      when 'A'
        'Authorized by a candidate'
      when 'B'
        'Lobbyist/Registrant PAC'
      when 'D'
        'Leadership PAC'
      when 'J'
        'Joint fundraiser'
      when 'P'
        'Principal campaign committee of a candidate'
      when 'U'
        'Unauthorized'
      end
    end

    def interest_group_category
      case org_tp
      when 'C'
        'Corporation'
      when 'L'
        'Labor organization'
      when 'M'
        'Membership organization'
      when 'T'
        'Trade association'
      when 'V'
        'Cooperative'
      when 'W'
        'Corporation without capital stock'
      else
        org_tp
      end
    end


    def committee_type
      case cmte_tp
      when 'C'
        ['Communication cost', 'Organizations like corporations or unions may prepare communications for their employees or members that advocate the election of specific candidates and they must disclose them under certain circumstances. These are usually paid with direct corporate or union funds rather than from PACs.' ]
      when 'D'
        ['Delegate committee', 'Delegate committees are organized for the purpose of influencing the selection of delegates to Presidential nominating conventions. The term includes a group of delegates, a group of individuals seeking to become delegates, and a group of individuals supporting delegates.']
      when 'E'
        ['Electioneering communication', 'Groups (other than PACs) making electioneering communications']
      when 'H'
        ['House', 'Campaign committees for candidates for the U.S. House of Representatives']
      when 'I'
        ['Independent expenditor (person or group)', "Individuals or groups (other than PACs) making independent expenditures over $250 in a year must disclose those expenditures"]
      when 'N'
        ['PAC - nonqualified', "PACs that have not yet been in existence for six months and received contributions from 50 people and made contributions to five federal candidates. These committees have lower limits for their contributions to candidates."]
      when 'O'
        ['Independent expenditure-only (Super PACs)', 'Political Committee that has filed a statement consistent with AO 2010-09 or AO 2010-11.']
      when 'P'
        ['Presidential', 'Campaign committee for candidate for U.S. President']
      when 'Q'
        ['PAC - qualified', 'PACs that have been in existence for six months and received contributions from 50 people and made contributions to five federal candidates']
      when 'S'
        ['Senate', 'Campaign committee for candidate for Senate']
      when 'U'
        ['Single-candidate independent expenditure', '']
      when 'V'
        ['PAC with non-contribution account - nonqualified', 'Political committees with non-contribution accounts']
      when 'W'
        ['PAC with non-contribution account - qaualified', 'Political committees with non-contribution accounts']
      when 'X'
        ['Party - nonqualified', 'Party committees that have not yet been in existence for six months and received contributions from 50 people, unless they are affiliated with another party committee that has met these requirements.']
      when 'Y'
        ['Party - qualified', 'Party committees that have existed for at least six months and received contributions from 50 people or are affiliated with another party committee that meets these requirements.']
      when 'Z'
        ['National party nonfederal account', 'National party nonfederal accounts. Not permitted after enactment of Bipartisan Campaign Reform Act of 2002.']
      end
    end

    def display_name
      "#{cmte_nm} (#{cmte_id})"
    end

    def propublica_url
      "https://projects.propublica.org/itemizer/committee/#{cmte_id}/#{fec_year}"
    end

    def create_littlesis_entity
      return entity if entity.present?

      Entity.create!(primary_ext: 'Org', name: cmte_nm.titleize).tap do |entity|
        entity.add_extension('PoliticalFundraising')
        entity.external_links.create!(link_type: :fec_committee, link_id: cmte_id)

        Rails.logger.info "Created LittleSis entity\##{entity.id} for FEC committee #{display_name}"
      end

      reload_entity
    end
  end
end
