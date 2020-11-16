# frozen_string_literal: true

class ExternalData
  module CreateFECDonorsService
    def self.run
      Rails.logger.info 'Create FEC Donors'

      # ExternalData.common_fec_contributionsfec_contribution.where(:TRANSACTION_TP => %i[committee earmarked pacs]).find_each do |ic|
      next if ic.NAME.blank?

      donor_name = NameParser.format(ic.NAME)
      employer = OrgName.parse(ic.EMPLOYER).clean if ic.EMPLOYER.present?

      attributes = { 'name' => donor_name,
                     'employer' => employer,
                     'city' =>  ic.CITY,
                     'state' => ic.STATE,
                     'zip_code' => ic.ZIP_CODE,
                     'occupation' => ic.OCCUPATION }

      fec_donor = find_or_build_donor(attributes)

      unless fec_donor.data['sub_ids'].include?(ic.SUB_ID)
        fec_donor.data['sub_ids'] << ic.SUB_ID
      end

      fec_donor.save!
      end

      Rails.logger.info "Updating FEC Donor data"

      ExternalData.fec_donor.find_each(&:update_fec_donor_data!)
    end

      # A "Donor" is a unique combination of Name + City + State + Zip_code + Employer + Occupation
    def self.find_or_build_donor(attributes)
      data = attributes.values_at(*%w[name, city, state, zip_code, employer, occupation])
      digest = Digest::MD5.digest(data.join(''))

      ExternalData.fec_donor.find_or_initialize_by(dataset_id: digest).tap do |record|
        unless record.persisted?

          record.data = { 'md5digest' => digest,
                          'sub_ids' => [],
                          'contributions' => nil,
                          'total_contributed' => nil }.merge!(attributes)
        end
      end
    end
  end
end
