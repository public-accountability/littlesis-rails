# frozen_string_literal: true

# donor = unique combination of Name + City + State + Zip_code + Employer + Occupation
class ExternalData
  module CreateFECDonorsService
    THREAD_COUNT = 5

    def self.run
      Rails.logger.info 'Create FEC Donors'

      Parallel.each(ExternalData.fec_contribution.find_in_batches, in_threads: THREAD_COUNT) do |batch|
        ExternalData.connection_pool.with_connection do
          batch.each { |ic| convert_contribution_to_donor(ic) }
        end
      end

      ExternalData.connection.reconnect!

      Rails.logger.info 'Updating FEC Donor data'

      Parallel.each(ExternalData.fec_donor.find_each, in_threads: THREAD_COUNT) do |fec_donor|
        ExternalData.connection_pool.with_connection do
          fec_donor.update_fec_donor_data!
        end
      end
    end

    def self.convert_contribution_to_donor(ic)
      return if ic.NAME.blank?

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


    # {name, city, state, zip_code, employer, occupation} ==> ExternalData.fec_donor
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
