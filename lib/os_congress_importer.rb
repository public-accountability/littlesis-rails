# Imports congressional data from Open Secrets
# Open Secrets data is found in their excel file: https://www.opensecrets.org/downloads/crp/CRP_IDs.xls 
# The Excel sheet must be first exported to csv with headers, delimiter: ',' quote: ''

require 'csv'

class OsCongressImporter
  attr_reader :list_id
  
  def initialize(filepath, lookup_filepath='data/members114_ids.csv')
    @filepath = filepath
    @lookup_filepath = lookup_filepath
    @id_lookup = id_lookup 
    @list_id = create_114_list
  end
  
  def process_row(row)
    entity_id = get_entity_id(row)
    if entity_id.nil?
      printf("Missing Entity Id: %s", row)
    else
      ListEntity.find_or_create_by(list_id: @list_id, entity_id: entity_id)
      add_relationship(row, entity_id)
    end
  end


  def get_entity_id(row)
    e = ElectedRepresentative.includes(:entity).find_by(crp_id: row['CID'], entity: {is_deleted: false })
    return e.entity_id unless e.nil?
    c = PoliticalCandidate.includes(:entity).find_by(crp_id: row['CID'], entity: {is_deleted: false })
    if c.nil?
      c = PoliticalCandidate.includes(:entity).find_by(house_fec_id: row['FECCandID'], entity: {is_deleted: false }) unless row['FECCandID'].nil?
    end
    if c.nil?
      entity_id = @id_lookup[row['CID']].to_i
    else
      entity_id = c.entity_id
    end
    if entity_id.nil?
      printf("Could not find id for:  \n %s  \n", row)
    else
      ElectedRepresentative.find_or_create_by(crp_id: row['CID'], entity_id: entity_id)
    end
    entity_id
  end
  
  def create_114_list
    l = List.new
    l.name = "114th Congress"
    l.last_user_id = 1
    l.save!
    return l.id
  end

  def add_relationship(row, entity_id)
    return nil unless (row['FECCandID'].slice(0) == "H")
    r = Relationship.find_or_create_by(
      entity1_id: entity_id, 
      entity2_id: 12884,
      category_id: 3,
      description1: "Representative", 
      description2: "Representative")
    
    if r.start_date.nil?
      printf("creating relationship for %s\n", entity_id)
      r.start_date = '2015-01-03'
      r.save
    end

  end

  def id_lookup
    ids = Hash.new
    CSV.read(@lookup_filepath, :headers => true).each do |line| 
      ids[line[0]] = line[2]
    end
    ids
  end

  def read_file
    CSV.foreach(@filepath, :headers => true ) do |row|
      process_row(row)
    end
  end

  def start
    read_file
  end
  
end
