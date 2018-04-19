# frozen_string_literal: true

class CmpRelationship < ApplicationRecord
  belongs_to :relationship
  validates :cmp_affiliation_id, presence: true, uniqueness: true
  validates :cmp_org_id, presence: true
  validates :cmp_person_id, presence: true
end
