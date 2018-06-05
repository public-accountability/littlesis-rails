# frozen_string_literal: true

module ExternalLinkUpdater
  extend ActiveSupport::Concern

  included do
    after_create :create_or_update_external_link, unless: ->(pc) { pc.sec_cik.blank? }
    after_update :create_or_update_external_link, if: -> { saved_change_to_attribute?('sec_cik') }
  end

  private

  def create_or_update_external_link
    if sec_cik.blank?
      ExternalLink
        .find_by(entity_id: entity_id, link_type: 'sec')
        &.destroy!
    else
      ExternalLink
        .find_or_initialize_by(entity_id: entity_id, link_type: 'sec')
        .update!(link_id: sec_cik.to_s)
    end
  end
end
