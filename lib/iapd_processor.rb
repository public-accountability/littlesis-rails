# frozen_string_literal: true

module IapdProcessor
  def self.run
    ExternalData.iapd_advisors.find_each do |external_data|
      ExternalEntity
        .iapd_advisors
        .find_or_create_by!(external_data: external_data)
        .automatch
    end

    ExternalData.iapd_schedule_a.find_each do |external_data|
      category_id = if external_data.data_wrapper.owner_primary_ext == 'Person'
                      Relationship::POSITION_CATEGORY
                    else
                      Relationship::OWNERSHIP_CATEGORY
                    end

      ExternalRelationship
        .iapd_schedule_a
        .find_or_create_by!(external_data: external_data, category_id: category_id)
    end
  end
end
