# frozen_string_literal: true

class ExternalData
  module Datasets
    class FECDonor < SimpleDelegator
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
        if employer == 'retired' || occupation.casecmp('retired').zero?
          'Retired'
        elsif employer == 'none' || employer == 'not employed' || occupation == 'NOT EMPLOYED'
          'Not employed'
        elsif employer.present? && occupation.blank?
          "Works at #{employer}"
        elsif employer.present? && occupation.present?
          "#{occupation.titleize} at #{employer}"
        end
      end

      def contributions
        "Contributed $#{self['total_contributed']} to #{self['contributions'].count} committees"
      end
    end
  end
end
