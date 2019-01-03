# frozen_string_literal: true

class EditedEntity < ApplicationRecord
  belongs_to :entity
  belongs_to :version, class_name: 'PaperTrail::Version', foreign_key: 'version_id', optional: true
  belongs_to :user, optional: true

  validates :entity_id, presence: true, uniqueness: { scope: :version_id }
  validates :version_id, presence: true
  validates :created_at, presence: true

  def self.create_from_version(version)
    return unless version.entity_edit?

    base_attributes = { user_id: version.whodunnit&.to_i,
                        version_id: version.id,
                        created_at: version.created_at }

    EditedEntity.create base_attributes.merge(entity_id: version.entity1_id)

    if version.entity2_id.present? && (version.entity2_id != version.entity1_id)
      EditedEntity.create base_attributes.merge(entity_id: version.entity2_id)
    end
  end

  def self.populate_table
    PaperTrail::Version.order(id: :asc).find_each do |version|
      create_from_version(version)
    end
  end
end
