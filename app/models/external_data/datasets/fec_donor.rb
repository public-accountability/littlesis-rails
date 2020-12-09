# frozen_string_literal: true

class ExternalData
  module Datasets
    class FECDonor < SimpleDelegator
      def nice
        @nice ||= { 'name' => name,
                    'location' => location,
                    'employment' => employment,
                    'contributions' => contributions }
      end

      def sub_ids
        self['sub_ids']
      end

      def location
        values_at('city', 'state', 'zip_code').join(', ')
      end

      def name
        self['name']
      end

      def employer
        self['employer']
      end

      def occupation
        self['occupation']
      end

      def employment
        if employer == 'retired' || occupation&.casecmp('retired')&.zero?
          'Retired'
        elsif /self[- ]employed/.match?(employer)
          occupation.presence || 'Self-employed'
        elsif employer == 'none' || employer == 'not employed' || occupation == 'NOT EMPLOYED'
          'Not employed'
        elsif employer.present? && occupation.blank?
          "Works at #{employer}"
        elsif employer.present? && occupation.present?
          "#{occupation.titleize} at #{employer}"
        end
      end

      def contributions
        if self['contributions'].nil?
          Rails.logger.warn "missing contribution data for #{self['md5digest']}"
          nil
        else
          "Contributed $#{self['total_contributed']} to #{self['contributions'].count} committees"
        end
      end
    end
  end
end
