# frozen_string_literal: true

require 'csv'
require_relative 'cmp/excel_sheet'
require_relative 'cmp/org_sheet'
require_relative 'cmp/person_sheet'
require_relative 'cmp/relationship_sheet'
require_relative 'cmp/org_type'
require_relative 'cmp/cmp_entity_importer'
require_relative 'cmp/entity_match'
require_relative 'cmp/cmp_org'
require_relative 'cmp/cmp_person'
require_relative 'cmp/cmp_relationship'
require_relative 'cmp/datasets'

module Cmp
  CMP_USER_ID = 9948
  CMP_SF_USER_ID = 8178
  CMP_TAG_ID = 11

  def self.import_orgs
    Cmp::Datasets.orgs.each(&:import!)
  end

  def self.set_whodunnit
    PaperTrail.request(whodunnit: CMP_USER_ID.to_s) { yield }
  end

  def self.transaction
    Cmp.set_whodunnit do
      ApplicationRecord.transaction do
        yield
      end
    end
  end
end
