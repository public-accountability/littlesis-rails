# frozen_string_literal

module FEC
  module NameNormalizer
    class Name < String
      attr_reader :type

      def initialize(str)
        @type = NameNormalizer.guess_type(str)

        case @type
        when
          :Org
          super(OrgName.parse(str).clean)
        when :Person
          super(NameParser.format(str))
        end

        freeze
      end
    end

    def self.parse(str)
      Name.new(str)
    end

    def self.guess_type(str)
      return :Org if is_org?(str)
      return :Person if is_person?(str)
      :Org  # default to org
    end

    def self.is_org?(str)
      return true if str.scan(' ').length.zero?
      return true if OrgName::SUFFIX_ACRONYMS_REGEX.match?(str)

      false
    end

    def self.is_person?(str)
      return false if is_org?(str)

      /\w{3,}, \w{3,}.*/.match?(str)
    end
  end
end
