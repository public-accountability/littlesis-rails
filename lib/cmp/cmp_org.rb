module Cmp
  class CmpOrg < Cmp::CmpEntityImporter
    # Mapping between cmp fields and Model/Attribute for entities
    ATTRIBUTE_MAP = {
      # :cmpname => [:entity, :name],
      :cmpmnemonic => [:org, :name_nick],
      :revenue => [:org, :revenue],
      :website => [:entity, :website],
      :city => [:address, :city],
      :country => [:address, :country_name],
      :latitude => [:address, :latitude],
      :longitude => [:address, :longitude],
      :ticker => [:public_company, :ticker]
    }.freeze

    def entity_match
      return @_entity_match if defined?(@_entity_match)
      @_entity_match = Cmp::EntityMatch.new name: @attributes.fetch(:cmpname), primary_ext: 'Org'
    end

    def to_h
      @attributes.merge(
        _matches: entity_match.count,
        url: entity_match.empty? ? "" : entity_url(entity_match.first)
      )
    end

    def import!
      ApplicationRecord.transaction do
        entity = find_or_create_entity
        create_cmp_entity(entity)
        entity.org.update! attrs_for(:org)
        entity.addresses.find_or_create_by! attrs_for(:address).with_last_user(CMP_USER_ID)
        import_ticker(entity)
      end
    end

    def find_or_create_entity
      if CmpEntity.find_by(cmp_id: cmpid)
        CmpEntity.find_by(cmp_id: cmpid).entity
      elsif !entity_match.empty?
        entity_match.match
      else
        create_new_entity!
      end
    end

    def create_cmp_entity(entity)
      CmpEntity.find_or_create_by!(entity: entity, cmp_id: cmpid, entity_type: :org)
    end

    private

    def import_ticker(entity)
      return nil unless attributes[:ticker].present?
      entity.add_extension('PublicCompany').public_company.update!(ticker: attributes[:ticker])
    end

    def attrs_for(model)
      LsHash.new(
        ATTRIBUTE_MAP
          .select { |_k, (m, _f)| m == model }
          .map { |k, (_m, f)|  [f, attributes[k]]
        }.to_h
      )
    end

    # -> <Entity>
    def create_new_entity!
      Entity.create!(
        primary_ext: 'Org',
        name: attributes[:cmpname],
        last_user_id: Cmp::CMP_USER_ID
      )
    end

  end
end
