# frozen_string_literal: true

module FEC
  class Donor < ApplicationRecord
    before_create :ensure_nulls # , :parse_name

    validates :name, presence: true

    has_many :donor_contributions
    has_many :individual_contributions, through: :donor_contributions
    # has_one :employer, through: :donor_employers

    def nice
      @nice ||= {
        name: name,
        city: city,
        state: state,
        zip_code: zip_code,
        employer: employer,
        total_contributed: contributions.map(&:amount).sum,
        contributions: contributions_by_committee,
        sub_ids: contributions.map(&:SUB_ID),
        md5digest: md5digest
      }
    end

    def contributions
      individual_contributions.where(:TRANSACTION_TP => %i[committee earmarked pacs])
    end

    def employment
      if employer == 'retired' || occupation.casecmp('retired').zero?
        "Retired"
      elsif employer == 'none' || employer == 'not employed' || occupation == 'NOT EMPLOYED'
        "Not employed"
      elsif employer.present? && occupation.blank?
        "Works at #{employer}"
      elsif employer.present? && occupation.present?
        "#{occupation.titleize} at #{employer}"
      end
    end

    def contributions_by_committee
      contributions.to_a.group_by(&:CMTE_ID).map do |cmte_id, contributions|
        {
          committee_name: contributions.first.committee.name,
          committee_id: cmte_id,
          amount: contributions.map(&:amount).sum,
          count: contributions.length,
          date_range: contributions_date_range
        }
      end
    end

    def contributions_date_range
      contributions
        .map(&:TRANSACTION_DT)
        .sort
        .values_at(0, contributions.length - 1)
        .map { |dt| Date.strptime(dt, "%m%d%Y") }
    end

    def md5digest
      Digest::MD5.hexdigest([name, city, state, zip_code, employer, occupation].join)
    end

    # When fields are fully-filled and not yet in the database this will create:
    #   DonorContribution
    #   Organization
    #   DonorEmployee
    def self.create_from_individual_contribution(ic)
      if ic.NAME.blank?
        FEC.logger.warn "Name is missing for contribution #{ic.SUB_ID}"
        return
      end

      donor_name = NameParser.format(ic.NAME)
      employer = OrgName.parse(ic.EMPLOYER).clean if ic.EMPLOYER.present?

      donor = find_or_create_by!(name: donor_name, city: ic.CITY, state: ic.STATE, zip_code: ic.ZIP_CODE, employer: employer, occupation: ic.OCCUPATION)

      DonorContribution.find_or_create_by!(donor_id: donor.id, individual_contribution_sub_id: ic.id)

      if employer
        employer_org = FEC::Organization.find_or_create_by!(name: employer)
        DonorEmployer.find_or_create_by!(donor_id: donor.id, organization_id: employer_org.id)
      end
    end

    private

    def ensure_nulls
      %i[city state zip_code employer occupation].each do |attr|
        write_attribute(attr, nil) if read_attribute(attr) == ''
      end
    end

    # def set_name_fields
    #   n = NameParser.new(self.name)
    #   self.name_first = n.first
    #   self.name_middle = n.middle
    #   self.name_last = n.last
    # end
  end
end
