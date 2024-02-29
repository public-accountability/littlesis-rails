#!/usr/bin/env -S rails runner

require 'csv'

# Open the CSV file
CORPU_RESULTS = Rails.root.join("data/corpu-compiled-cleaned.24-02-20.csv")

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

CORPU_TAG_ID = 37
FF_TAG_ID = 34
CORPU_LIST_ID = 3508
FF_LIST_ID = 3509
DUPE_TAG_ID = 38

def is_board_member(details)
  if details.present?
    details = details.downcase
    if details.include?("board member") ||
       details.include?("chairman") ||
       details.include?("president")
     return true
    end
  end
  nil
end

def tag_entity(tag_id, tagable_type, tagable_id)
  # This next find line is to prevent duplicates in this particular import case
  tagging = Tagging.find_by(tag_id: tag_id, tagable_id: tagable_id)
  if !tagging.present?
    # Tag Object
    Tagging.create({
      tag_id: tag_id,
      tagable_class: tagable_type,
      tagable_id: tagable_id
    })
  end
end

def find_entity(name)
  entity = Entity.find_by(name: name)
  return entity
end

def create_entity(name, blurb, entity_type, source)
  # This next find line is to prevent duplicates in this particular import case
  entity = find_entity(name)
  if !entity.present?
    entity = Entity.create({
      name: name,
      blurb: blurb,
      primary_ext: entity_type
    })
  end
  # TODO what if the entity already exists but the blurb is empty?
  return entity[:id]
end

def find_relationship(person_id, org_id)
  relationship = Relationship.find_by({entity1_id: person_id, entity2_id: org_id})
  return relationship
end

def update_relationship(relationship_id, title)
  relationship = Relationship.find(relationship_id)
  relationship.update({description1: title})
  return relationship[:id]
end

def create_relationship(person_id, org_id, category_id, title, is_current = nil)
  relationship = Relationship.create({
    entity1_id: person_id,
    entity2_id: org_id,
    category_id: category_id,
    description1: title,
    is_current: is_current == '1' ? false : nil
  })
  if is_board_member(title)
    relationship.position.update(is_board: true)
  end
  return relationship[:id]
end

def create_relationship_source(relationship_id, url)
  relationship = Relationship.find(relationship_id)
  relationship.add_reference({url: url})
end

def add_entity_to_list(list_id, entity_id)
  list_entity = ListEntity.find_by({list_id: list_id, entity_id: entity_id})
  if !list_entity.present?
    list_entity = ListEntity.create({
      list_id: list_id,
      entity_id: entity_id
    })
  end
end

# Loop through the rows of the CSV
CSV.foreach(CORPU_RESULTS, headers: true) do |row|

  # Create Person if it doesn't automatch
  if row['entity_automatch'] != '1'
    person_id = create_entity(
      row['Name'],
      row['Blurb'],
      'Person',
      row['Relevant Sources']
    )
  else
    person_id = row['entity_id']
  end
  # Tag the Person with CorpU
  tag_entity(CORPU_TAG_ID, 'Entity', person_id)
  # Add the Person to the CorpU List
  add_entity_to_list(CORPU_LIST_ID, person_id)
  # If the Person has a Fossil Fuel Tie,
  # also tag and list them accordingly
  if row['Fossil Fuel Tie'] == '1'
    tag_entity(FF_TAG_ID, 'Entity', person_id)
    add_entity_to_list(FF_LIST_ID, person_id)
  end
  # Tag close automatch as a possible duplicate
  if row['entity_automatch'] != '0'
    tag_entity(DUPE_TAG_ID, 'Entity', person_id)
  end
  
  if row['Corporate Entity'].present?
    # Create Org if it doesn't automatch
    if row['other_entity_automatch'] != '1'
      org_id = create_entity(
        row['Corporate Entity'],
        nil,
        'Org',
        row['Relevant Sources']
      )
    else
      org_id = row['other_entity_id']
    end
    # Tag the Org with CorpU
    tag_entity(CORPU_TAG_ID, 'Entity', org_id)
    # Tag close automatch as a possible duplicate
    if row['entity_automatch'] != '0'
      tag_entity(DUPE_TAG_ID, 'Entity', org_id)
    end
    # Add the Org to the CorpU List
    add_entity_to_list(CORPU_LIST_ID, org_id)
   
    # Create Relationship if it doesn't exist
    if !row["other_entity_existing_relationship"].present?
      existing_org_relationship = find_relationship(person_id, org_id)
      if !existing_org_relationship
        org_relationship_id = create_relationship(
          person_id,
          org_id,
          1,
          row['Position'],
          row['Position in Past']
        )
        if row['Relevant Sources'].present?
          create_relationship_source(org_relationship_id, row['Relevant Sources'])
        end
        if row['Relevant Sources 2'].present?
          create_relationship_source(org_relationship_id, row['Relevant Sources 2'])
        end
        if row['Relevant Sources 3'].present?
          create_relationship_source(org_relationship_id, row['Relevant Sources 3'])
        end
      else
        org_relationship_id = update_relationship(existing_org_relationship[:id], row['Position'])
      end
    end
    # Tag the org relationship with CorpU
    tag_entity(CORPU_TAG_ID, 'Relationship', org_relationship_id)
  end

  # Create Board Relationship to the school
  school_id = Universities.fetch(row['School'])
  existing_school_relationship = find_relationship(person_id, org_id)
  if !existing_school_relationship
    school_relationship_id = create_relationship(
      person_id,
      school_id,
      1,
      'Board Member'
    )
    if row['Relevant Sources'].present?
      create_relationship_source(school_relationship_id, row['Relevant Sources'])
    end
    if row['Relevant Sources 2'].present?
      create_relationship_source(school_relationship_id, row['Relevant Sources 2'])
    end
    if row['Relevant Sources 3'].present?
      create_relationship_source(school_relationship_id, row['Relevant Sources 3'])
    end
  else
    school_relationship_id = update_relationship(existing_school_relationship[:id], 'Board Member')
  end
  # Tag the school with CorpU
  tag_entity(CORPU_TAG_ID, 'Entity', school_id)
  # Tag the school relationship with CorpU
  tag_entity(CORPU_TAG_ID, 'Relationship', school_relationship_id)
  # Add the School to the CorpU List
  add_entity_to_list(CORPU_LIST_ID, school_id)

end
