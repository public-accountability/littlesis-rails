# frozen_string_literal: true

class IapdDatum < ExternalDataset
  IapdAdvisor = Struct.new(:crd_number, :name, :data)
  IapdOwner = Struct.new(:owner_key, :name, :associated_advisors, :data) do
    def owner_type
      owner_types = data.map { |d| d['owner_type'] }.uniq
      if owner_types.length != 1 && owner_types.include?('I')
        Rails.logger.warn "Conflicting owner type in Iapd dataset. Ownerkey = #{owner_key}"
        nil
      else
        owner_types.first == 'I' ? :person : :org
      end
    end
  end

  def filing_ids
    row_data['data'].map { |x| x.fetch('filing_id') }.uniq
  end

  # Returns CRD numbers of the adivsors for the owner
  # see IapdImporter.owner_to_struct
  # --> [Int]
  def associated_advisors
    method_only_for! :owner

    row_data.fetch('associated_advisors')
  end

  def filings_for_advisor(crd_number)
    method_only_for! :owner

    row_data['data'].filter { |x| x['advisor_crd_number'] == crd_number }
  end

  def add_to_matching_queue
    method_only_for! :owner
  end

  # Retrieves associated owners for the advisor.
  # --> [IapdDatum]
  def owners
    method_only_for! :advisor

    self.class.owners_of_crd_number row_data.fetch('crd_number')
  end

  def owner?
    row_data_class == IapdOwner.name
  end

  def advisor?
    row_data_class == IapdAdvisor.name
  end

  ## Class Query Methods ##

  def self.owners
    where(Arel.sql("JSON_VALUE(row_data, '$.class') = 'IapdDatum::IapdOwner'"))
  end

  def self.advisors
    where(Arel.sql("JSON_VALUE(row_data, '$.class') = 'IapdDatum::IapdAdvisor'"))
  end

  def self.owners_of_crd_number(crd_number)
    owners.where(Arel.sql("JSON_CONTAINS(row_data, #{crd_number}, '$.associated_advisors')"))
  end

  private

  def method_only_for!(iapd_type)
    case iapd_type
    when :owner
      raise Exceptions::LittleSisError, 'Ipad Owner method called on an advisor' if advisor?
    when :advisor
      raise Exceptions::LittleSisError, 'Ipad Advisor method called on an owner' if owner?
    else
      raise ArgumentError
    end
  end
end
