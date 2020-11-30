# frozen_string_literal: true

class ExternalData
  module Datasets
    class FECContribution < SimpleDelegator
      def self.calculate_date_range(contributions)
        dates = contributions.map { |c| c.wrapper.date }.compact.sort

        case dates.length
        when 0
          nil
        when 1
          [dates.first, dates.first]
        else
          dates.values_at(0, dates.length - 1)
        end
      end

      # This find and updates or creates a new record in ExternalData
      # ic = FEC::IndividualContribution
      # output = ExternalData.fec_contributions
      def self.import_or_update(ic)
        ExternalData.fec_contribution.find_or_initialize_by(dataset_id: ic.SUB_ID).tap do |ed|
          ed.merge_data(ic.attributes)
          ed.save!
          ed.external_relationship || ed.create_external_relationship!(dataset: ed.dataset, category_id: Relationship::DONATION_CATEGORY)
        end
      rescue ActiveRecord::ActiveRecordError => e
        Rails.logger.warn "Failed to import #{ic.SUB_ID}. Error: #{e.message}"
      end

      def donor_attributes
        {
          'name' => name,
          'city' => self['CITY'],
          'state' => self['STATE'],
          'zip_code' => self['ZIP_CODE'],
          'employer' => employer,
          'occupation' => self['OCCUPATION'],
          'md5digest' => md5digest
        }
      end

      def md5digest
        @md5digest ||= Digest::MD5.hexdigest([name, city, state, zip_code, employer, occupation].join(''))
      end

      alias digest md5digest

      def name
        return nil if self['NAME'].blank?

        @name ||= NameParser.format(self['NAME'])
      end

      def city
        self['CITY']
      end

      def state
        self['STATE']
      end

      def zip_code
        self['ZIP_CODE']
      end

      def employer
        return nil if self['EMPLOYER'].blank?

        @employer ||= OrgName.parse(self['EMPLOYER']).clean
      end

      def occupation
        self['OCCUPATION']
      end

      def sub_id
        self['SUB_ID']
      end

      def amount
        self['TRANSACTION_AMT'].to_f.round(2)
      end

      def date
        LsDate.parse_fec_date self['TRANSACTION_DT']
      end

      def committee_id
        self['CMTE_ID']
      end

      def image_number
        self['IMAGE_NUM']
      end

      def document_attributes
        {
          name: "FEC Filing #{image_number}",
          url: "https://docquery.fec.gov/cgi-bin/fecimg/?#{image_number}"
        }
      end
    end
  end
end
