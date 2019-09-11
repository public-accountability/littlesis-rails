# frozen_string_literal: true

module ExternalDatasetService
  class Iapd < Base
    def self.crd_number?(crd)
      return false if crd.blank? || crd.include?('-')

      /\A\d+\z/.match?(crd)
    end

    def validate_match!
      requies_entity!

      return if crd_number.blank?

      external_link = @entity.external_links.find_by(link_type: :crd)

      # Entity already has an external link with same the value.
      # The entity has likely already been matched.
      return if external_link && external_link.link_id.to_i == crd_number.to_i

      if ExternalLink.exists?(link_type: :crd, link_id: crd_number)
        msg = "Another entity has already claimed the crd number #{crd_number}. Cannot match row #{@external_dataset.id}"
        raise InvalidMatchError, msg
      end
    end

    def match
      return :already_matched if @external_dataset.matched?

      validate_match!

      extension_attrs = {}

      ApplicationRecord.transaction do
        @entity.add_tag(IapdDatum::IAPD_TAG_ID)

        crd_numbers_for_documentation.each do |crd_number|
          @entity.add_reference(IapdDatum.document_attributes_for_form_adv_pdf(crd_number))
        end

        # Create an crd external link. Not all Iapd Owners have crd numbers.
        if crd_number.present?
          @entity.external_links.create! link_type: :crd, link_id: crd_number
        end

        if @external_dataset.advisor?
          aum = @external_dataset.row_data['data'].first['assets_under_management']&.to_i
          extension_attrs[:aum] = aum unless aum.nil? || aum.zero?
        end
  
        if @entity.has_extension?(extension_type)
          @entity.merge_extension extension_type, extension_attrs
        else
          @entity.add_extension extension_type, extension_attrs
        end

        external_dataset.update! entity_id: @entity.id
        @entity.save!
      end

      if external_dataset.advisor?
        external_dataset.owners.map do |owner|
          IapdRelationshipService.new(advisor: external_dataset, owner: owner)
        end
      elsif external_dataset.owner?
        external_dataset.advisors.map do |advisor|
          IapdRelationshipService.new(advisor: advisor, owner: external_dataset)
        end
      end
    end

    def unmatch
      ApplicationRecord.transaction do
        if crd_number.present?
          @entity.external_links.find_by(link_type: :crd, link_id: crd_number)&.destroy!
        end
        @external_dataset.update! entity_id: nil
      end
    end

    private

    def extension_type
      @external_dataset.org? ? 'Business' : 'BusinessPerson'
    end

    def crd_numbers_for_documentation
      if @external_dataset.advisor?
        Array.wrap(@external_dataset.row_data.fetch('crd_number'))
      elsif @external_dataset.owner?
        @external_dataset.row_data.fetch('associated_advisors')
      end
    end

    def crd_number
      if @external_dataset.row_data_class&.include? 'IapdAdvisor'
        @external_dataset.row_data.fetch('crd_number')
      elsif @external_dataset.row_data_class&.include? 'IapdOwner'
        owner_key = @external_dataset.row_data.fetch('owner_key')
        return owner_key if self.class.crd_number?(owner_key)
      end
    end
  end
end
