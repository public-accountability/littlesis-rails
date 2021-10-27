# frozen_string_literal: true

class NyMatch < ApplicationRecord
  belongs_to :ny_disclosure, inverse_of: :ny_match
  has_one :ny_filer, :through => :ny_disclosure
  has_one :ny_filer_entity, :through => :ny_filer
  belongs_to :donor, class_name: 'Entity', foreign_key: 'donor_id'
  belongs_to :recipient, class_name: 'Entity', foreign_key: 'recip_id', optional: true
  belongs_to :relationship, optional: true
  belongs_to :user, foreign_key: 'matched_by', optional: true

  validates :ny_disclosure_id, presence: true
  validates :donor_id, presence: true

  def create_or_update_relationship
    # if this match already has a relationship, so we can assume this has already been processed
    return nil unless relationship.nil?
    # a relationship requires both a donor and a recipient
    return nil if donor_id.nil? || recip_id.nil?
    # find the existing relationship (or create it)
    r = Relationship.find_or_create_by!(relationship_params)
    r.last_user_id = last_user_id_for_relationship
    # connect this match to the relationship
    update_attribute(:relationship, r)
    # update and save the relationship
    r.update_ny_donation_info.save
    create_reference(r)
  end

  def set_recipient
    self.recip_id = NyFilerEntity.find_by(filer_id: ny_disclosure.filer_id).try(:entity_id)
  end

  # input: int, int, int (optional)
  # output: NyMatch
  # Matches the NY disclosure with the donor.
  def self.match(disclosure_id, donor_id, matched_by=Rails.application.config.littlesis[:system_user_id])
    m = find_or_initialize_by(ny_disclosure_id: disclosure_id, donor_id: donor_id)
    if m.new_record?
      m.matched_by = matched_by
      m.set_recipient
      m.create_or_update_relationship
      m.recipient.try(:touch)
      m.save
    end
    return m
  end

  def unmatch!
    destroy!
    if relationship.present?
      relationship.update_ny_donation_info.save!
      relationship.soft_delete unless relationship.ny_matches.exists?
    end
  end

  def rematch
    set_recipient
    create_or_update_relationship
  end

  # Returns information as hash for the review donations page
  def info
    ny_disclosure
      .contribution_attributes
      .merge(:filer_in_littlesis => ny_filer.is_matched? ? 'Y' : 'N', :ny_match_id => id)
  end

  private

  # input: Relationship
  def create_reference(rel)
    ref_link = ny_disclosure.reference_link
    unless rel.references.map { |ref| ref.document.url }.include? ref_link.strip
      rel.add_reference(url: ref_link, name: ny_disclosure.reference_name)
    end
  end

  def relationship_params
    {
      entity1_id: donor_id,
      entity2_id: recip_id,
      category_id: 5,
      # This avoids problems caused if federal campaign contributions also exist for the
      # same politician. However, it requires that every NYS campaign contribution
      # relationship have the description set to this string.
      description1: "NYS Campaign Contribution"
    }
  end

  def last_user_id_for_relationship
    if matched_by.nil? || (persisted? && updated_at < 1.minute.ago)
      Rails.application.config.littlesis[:system_user_id]
    else
      matched_by
    end
  end
end
