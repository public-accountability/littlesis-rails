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
      ExternalRelationship
        .iapd_schedule_a
        .find_or_create_by!(external_data: external_data, category_id: Relationship::POSITION_CATEGORY)
    end
  end
end
