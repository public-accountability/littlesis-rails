#!/usr/bin/env -S rails runner
#
# Takes corpu-results and create 4 csv files in data/
# corpu-universities, corpu-entities, corpu-relationships, corpu-existing_relationships

CORPU_RESULTS = File.expand_path("~/Documents/corpu/corpu_results-2023-09-18.csv")

require 'csv'

Universities = {
  'MIT' => 14933,
  'Brown' => 15175,
  'Columbia' => 14924,
  'Cornell' => 15057,
  'Dartmouth' => 15061,
  'Duke' => 15105,
  'FL_State' => 34122,
  'Georgetown' => 15196,
  'Harvard_Corporation' => 267445,
  'Harvard_Overseers' => 402987,
  'Michigan' => 14989,
  'Morgan_St' => 52324,
  'NYU' => 15003,
  'Princeton' => 14950,
  'StJohns' => 33961,
  'Temple' => 15272,
  'UCONN_Foundation' => 142084,
  'UC_Berkeley' => 68692,
  'UC_Regents' => 407075,
  'UC_San_Diego_Foundation' => 48770,
  'UC_Santa_Cruz_Foundation' => 142439,
  'UConn' => 42367,
  'UNC_Chapel_Hill' => 33907,
  'USD' => 34395,
  'U_Penn' => 14957,
  'U_Penn_Wharton' => 14959,
  'Williams' => 15200
}


# [name,blurb,primary_ext,description1]   # ,is_current,start_date,end_date,is_board,is_executive,compensation,notes]
# ["Name", "Industry", "If Other, what", "Corporate entity", "Position details", "FF-tie Other", "Past", "Notes", "Relevant sources", "corpu", "entity_automatch", "entity_name", "entity_id", "entity_url", "other_entity_automatch", "other_entity_name", "other_entity_id", "other_entity_url", "other_entity_existing_relationship"]

NewEntity = Struct.new(:name, :blub, :primary_ext)
NewPositionRelationship = Struct.new(:entity1,
                                     :entity2,
                                     :description1,
                                     :is_current,
                                     :board_member,
                                     :notes,
                                     :entity1_automatch,
                                     :entity2_automatch,
                                     :entity1_name,
                                     :entity2_name,
                                     :entity1_url,
                                     :entity2_url,
                                     keyword_init: true)

entities = []
relationships = []
existing_relationships = []

def is_board_member(details)
  details = details.downcase
  if details.include?("board member") || details.include?("chairman") || details.include?("president")
    return true
  end
  nil
end

CSV.foreach(CORPU_RESULTS, headers: true) do |row|
  entity1_automatch = row['entity_automatch']&.strip&.downcase == 'true'
  entity2_automatch = row['other_entity_automatch']&.strip&.downcase == 'true'

  entity1 = if entity1_automatch
              row['entity_id']  # use automatch entity
            else
              # add entity to list of entities to be created if needed
              unless entities.map(&:name).include?(row['Name'])
                entities << NewEntity.new(row['Name'], "Board member of #{row['corpu'].titleize}", "Person")
              end
              # set entity1_id to be the name of entity that will be created
              row['Name']
            end

  # add school relationship
  unless relationships.find { |r| r.entity1 == entity1 && r.entity2 == Universities.fetch(row['corpu']) }
    school = Entity.find(Universities.fetch(row['corpu']))

    relationships << NewPositionRelationship.new(
      entity1: entity1,
      entity2: school.id,
      board_member: true,
      entity1_automatch: entity1_automatch,
      entity2_automatch: true,
      entity1_name: entity1_automatch ? row['entity_name'] : row['Name'],
      entity2_name: school.name,
      entity1_url: entity1_automatch ? row['entity_url'] : nil,
      entity2_url: school.url
    )
  end

  # add corporate relationship
  if row["Corporate entity"].present?
    if row["other_entity_existing_relationship"].present?
      existing_relationships << row["other_entity_existing_relationship"]
    else

      entity2 = if entity2_automatch
                  row["other_entity_id"]
                else
                  # create org
                  unless entities.map(&:name).include?(row["Corporate entity"])
                    entities << NewEntity.new(row["Corporate entity"], nil, "Org")
                  end

                  row["Corporate entity"]
                end

      relationships << NewPositionRelationship.new(entity1: entity1,
                                                   entity2: entity2,
                                                   description1: row["Position details"]&.tr('""', ''),
                                                   is_current: row['Past'] == '1' ? true : nil,
                                                   board_member: is_board_member(row["Position details"] || ""),
                                                   notes: row['Notes'],
                                                   entity1_automatch: entity1_automatch,
                                                   entity2_automatch: entity2_automatch,
                                                   entity1_name: entity1_automatch ? row['entity_name'] : row['Name'],
                                                   entity2_name: entity2_automatch ? row['other_entity_name'] : row["Corporate entity"],
                                                   entity1_url: entity1_automatch ? row['entity_url'] : nil,
                                                   entity2_url: entity2_automatch ? row['other_entity_url'] : nil,
                                                  )
    end
  end
end

def corpu_filepath(name)
  Rails.root.join('data', "corpu-#{name}-#{Time.current.strftime('%F')}.csv")
end

Utility.save_hash_array_to_csv(corpu_filepath('universities'), Entity.find(Universities.values).map(&:to_hash))

Utility.save_hash_array_to_csv(corpu_filepath('entities'),  entities.map(&:to_h))

Utility.save_hash_array_to_csv(corpu_filepath('relationships'),  relationships.map(&:to_h))

File.write(corpu_filepath('existing_relationships'), existing_relationships.join("\n"))
