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
require_relative 'cmp/datasets'

module Cmp
  CMP_USER_ID = 1
  CMP_SF_USER_ID = 1
  CMP_TAG_ID = 11

  ORG_FILE_PATH = Rails.root.join('data', 'CMPDatabase2_Organizations_2015-2016.xlsx').to_s
  ORG_OUT_CSV_PATH = Rails.root.join('data', "cmp-orgs-#{Time.current.strftime('%F')}.csv").to_s

  RELATIONSHIP_FILE_PATH = Rails.root.join('data', 'affiliations', 'affiliations.csv').to_s

  def self.affliations
    RelationshipSheet.new(RELATIONSHIP_FILE_PATH).to_a
  end

  def self.save_org_csv
    Query.save_hash_array_to_csv ORG_OUT_CSV_PATH, orgs.map(&:to_h)
  end

  def self.save_person_csv
    Query.save_hash_array_to_csv PERSON_OUT_CSV_PATH, people.map(&:to_h)
  end

  # -> [CmpOrg]
  def self.orgs(file_path = ORG_FILE_PATH)
    OrgSheet.new(file_path).to_a.map { |attrs| CmpOrg.new(attrs) }
  end

  def self.import_orgs
    orgs.each(&:import!)
  end

  # -> [CmpPerson]
  def self.people(file_path = PERSON_FILE_PATH)
    PersonSheet.new(file_path).to_a.map { |attrs| CmpPerson.new(attrs) }
  end
end
