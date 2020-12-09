# frozen_string_literal: true

class Reference < ApplicationRecord
  include Api::Serializable
  belongs_to :referenceable, polymorphic: true
  belongs_to :document
  validates_presence_of :referenceable_type, :referenceable_id, :document_id
end
