# frozen_string_literal: true

class IapdDatum < ExternalDataset
  IapdAdvisor = Struct.new(:crd_number, :name, :data)
  IapdOwner = Struct.new(:owner_key, :name, :data) do
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
end
