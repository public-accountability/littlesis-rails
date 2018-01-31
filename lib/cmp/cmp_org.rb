module Cmp
  class CmpOrg < CmpEntityImporter
    attr_reader :org_type

    # Mapping between cmp fields and Model/Attribute for entities
    ATTRIBUTE_MAP = {
      # :cmpname => [:entity, :name],
      :cmpmnemonic => [:org, :name_nick],
      :revenue => [:org, :revenue],
      :website => [:entity, :website],
      :is_current => [:entity, :is_current],
      :city => [:address, :city],
      :country => [:address, :country_name],
      :latitude => [:address, :latitude],
      :longitude => [:address, :longitude],
      :ticker => [:public_company, :ticker],
      :assets => [:business, :assets]
    }.freeze

    def initialize(*args)
      super(*args)
      @org_type = OrgType.new fetch(:orgtype_code)
      parse_fields
    end

    def entity_match
      return @_entity_match if defined?(@_entity_match)
      @_entity_match = Cmp::EntityMatch.new name: fetch(:cmpname), primary_ext: 'Org', cmpid: cmpid
    end

    def matches
      return {} if entity_match.empty?
      one = { one: entity_str(entity_match.first) }
      return one.merge(two: entity_str(entity_match.second)) if entity_match.second.present?
      return one
    end

    def import!
      ApplicationRecord.transaction do
        entity = find_or_create_entity
        return if entity.nil?
        create_cmp_entity(entity)
        entity.update! attrs_for(:entity).with_last_user(CMP_SF_USER_ID)
        add_extension(entity)
        entity.org.update! attrs_for(:org)
        import_address(entity)
        import_ticker(entity)
      end
    end

    def find_or_create_entity
      if CmpEntity.find_by(cmp_id: cmpid)
        CmpEntity.find_by(cmp_id: cmpid).entity
      elsif entity_match.has_match?

        if CmpEntity.find_by(entity_id: entity_match.match.id).present?
          Rails.logger.warn <<~ERROR
            Failed to import Cmp Org \##{cmpid}
            The matched entity -- #{entity_match.match.id} -- already has a CmpEntity
          ERROR
          return nil
        else
          entity_match.match
        end

      else
        create_new_entity!
      end
    end

    private

    # Modifies fields as needed from CMP
    # - adds 'assets' as latest provided value from 2014-2016
    # - adds 'is_current' based if status is active
    def parse_fields
      attributes
        .store(:assets, attributes.values_at(:assets_2016, :assets_2015, :assets_2014).compact.first)
      attributes.store(:is_current, fetch(:status, nil) == 'active' ? true : nil)
    end

    def create_cmp_entity(entity)
      CmpEntity.find_or_create_by!(entity: entity, cmp_id: cmpid, entity_type: :org)
    end

    def add_extension(entity)
      entity.add_extension(org_type.extension) unless org_type.extension.nil?
    end

    def import_ticker(entity)
      return nil if attributes[:ticker].blank?
      entity.add_extension('PublicCompany').public_company.update!(ticker: attributes[:ticker])
    end

    def import_address(entity)
      attrs = attrs_for(:address).with_last_user(CMP_SF_USER_ID)
      unless attrs[:city].blank? || attrs[:country_name].blank?
        entity.addresses.find_or_create_by!(attrs)
      end
    end

    # -> <Entity>
    def create_new_entity!
      Entity.create!(
        primary_ext: 'Org',
        name: attributes[:cmpname],
        last_user_id: Cmp::CMP_USER_ID
      )
    end

    def entity_str(entity)
      "#{entity.name} - #{entity_url(entity)}"
    end
  end
end
