# frozen_string_literal: true

# The ExternalData "data" column for iapd owners is an array of hashes.
# Each hash represents an owner relationship derived from an SEC filing.
# Each filing has multiple owners and it is common for a single person
# to have both a schedule A (direct relationship) and schedule B (indirect ownership)
# on the same filing.
class ExternalData
  class IapdOwner
    attr_reader :primary_ext

    def initialize(data) # input is the "data" field from ExternalData
      @data = data
      @primary_ext = primary_extension(@data)
    end

    def person?
      @primary_ext == 'Person'
    end

    def org?
      !person?
    end

    # def filing_ids
      # @data.map { |x| x.fetch('filing_id') }.uniq
    # end

    def associated_advisors
    end

    private

    def primary_extension(data)
      owner_types = data.map { |d| d['owner_type'] }.uniq

      if owner_types.length != 1 && owner_types.include?('I')
        raise Exceptions::LittleSisError,
              "Conflicting owner type in Iapd dataset. Ownerkey = #{owner_key}"
      else
        owner_types.first == 'I' ? 'Person' : 'Org'
      end
    end
  end
end
