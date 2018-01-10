require 'csv'

module Cmp
  ORG_FILE_PATH = Rails.root.join('data', 'CMPDatabase2_Organizations_2015-2016.xlsx').to_s
  ORG_OUT_CSV_PATH = Rails.root.join('data', "cmp-orgs-#{Time.now.strftime('%F')}.csv").to_s

  PERSON_FILE_PATH = Rails.root.join('data', 'CMPDatabase2_Individuals.xlsx').to_s
  PERSON_OUT_CSV_PATH = Rails.root.join('data', "cmp-individuals-#{Time.now.strftime('%F')}.csv").to_s
  
  def self.save_org_csv
    Query.save_hash_array_to_csv ORG_OUT_CSV_PATH, orgs.map(&:to_h)
  end
    
  def self.save_person_csv
    Query.save_hash_array_to_csv PERSON_OUT_CSV_PATH, people.map(&:to_h)
  end

  # -> [CmpOrg]
  def self.orgs
    OrgSheet.new(ORG_FILE_PATH).to_a.map { |attrs| CmpOrg.new(attrs) }
  end

  def self.people
    PersonSheet.new(PERSON_FILE_PATH).to_a.map { |attrs| CmpPerson.new(attrs) }
  end
end
