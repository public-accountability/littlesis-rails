# frozen_string_literal: true

class EditedEntity < ApplicationRecord
  belongs_to :entity
  belongs_to :version, class_name: 'PaperTrail::Version', foreign_key: 'version_id', optional: true
  belongs_to :user, optional: true

  validates :entity_id, presence: true
  validates :version_id, presence: true
  validates :created_at, presence: true
end
