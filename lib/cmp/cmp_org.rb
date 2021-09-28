# frozen_string_literal: true

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
      @_entity_match = find_entity_match
    end

    def import!
      Rails.logger.debug "Importing: #{cmpid}"

      Cmp.set_whodunnit do
        ApplicationRecord.transaction do
          entity = find_or_create_entity
          return if entity.nil?
          create_cmp_entity(entity)
          entity.update! attrs_for(:entity)
          add_extension(entity)
          entity.add_tag(Cmp::CMP_TAG_ID)
          entity.org.update! attrs_for(:org)
          import_address(entity)
          import_ticker(entity)
          unless entity.reload.last_user_id == Cmp::CMP_USER_ID
            entity.update_columns(last_user_id: Cmp::CMP_USER_ID)
          end
        end
      end
    end

    def find_or_create_entity
      if CmpEntity.find_by(cmp_id: cmpid)
        CmpEntity.find_by(cmp_id: cmpid).entity
      elsif preselected_match
        if preselected_match.to_s.casecmp('NEW').zero?
          create_new_entity!
        else
          Entity.find(preselected_match)
        end
      elsif entity_match
        if CmpEntity.find_by(entity_id: entity_match.id).present?
          Rails.logger.warn <<~ERROR
            Failed to import Cmp Org \##{cmpid}
            The matched entity -- #{entity_match.id} -- already has a CmpEntity
          ERROR
          return nil
        else
          entity_match
        end
      else
        create_new_entity!
      end
    end

    private

    def preselected_match
      Cmp::EntityMatch.matches.dig(cmpid.to_s, 'entity_id')
    end

    def find_entity_match
      matches = EntityMatcher.find_matches_for_org(fetch(:cmpname))
      return matches.first.entity if matches&.first&.automatch?
    end

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
      attrs = attrs_for(:address)
      unless attrs[:city].blank? || attrs[:country_name].blank?
        entity.addresses.find_or_create_by!(attrs)
      end
    end

    # -> <Entity>
    def create_new_entity!
      Entity.create!(
        primary_ext: 'Org',
        name: OrgName.format(attributes[:cmpname]),
        last_user_id: Cmp::CMP_USER_ID
      )
    end
  end
end
