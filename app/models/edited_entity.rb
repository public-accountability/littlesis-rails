# frozen_string_literal: true

class EditedEntity < ApplicationRecord
  belongs_to :entity
  belongs_to :version, class_name: 'PaperTrail::Version', foreign_key: 'version_id'
  belongs_to :user
end
