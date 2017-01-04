# used by rake task landing_teams
require 'csv'

module LandingTeams

  AGENCIES = {
    'Commodity Futures and Trading Commission' => 14737,
    'Consumer Financial Protection Bureau' => 90471,
    'Department of Agriculture' => 14603,
    'Department of Commerce' => 14619,
    'Department of Defense' => 14609,
    'Department of Education' => 14637,
    'Department of Energy' => 14658,
    'Department of Health and Human Services' => 14640, 
    'Department of Homeland Security' => 14617,
    'Department of Housing and Urban Development' => 16072,
    'Department of the Interior' => 14611,
    'Department of Justice' => 14605,
    'Department of Labor' => 14682,
    'Department of State' => 14615,
    'Department of Transportation' => 14607,
    'Department of the Treasury' => 14629,
    'Department of Veterans Affairs' => 37205,
    'Environmental Protection Agency' => 14628,
    'Export-Import Bank' => 40055,
    'Farm Credit Administration' => 49647,
    'Federal Communications Commission' => 14685,
    'Federal Deposit Insurance Corporation' => 15490,
    'Federal Energy Regulatory Commission' => 14698,
    'Federal Housing Finance Agency' => 94620,
    'Federal Reserve Board' => 15957,
    'Financial Stability Oversight Council' => 254740,
    'Federal Trade Commission' => 14724,
    'General Services Administration' => 14624,
    'National Aeronautics and Space Administration' => 14655,
    'National Credit Union Administration' => 26588,
    'National Security Council' => 15575,
    'Office of the Comptroller of the Currency' => 14722,
    'Office of the Director of National Intelligence' => 17006,
    'Office of Management and Budget' => 15586,
    'Office of Personnel Management' => 14669,
    'Office of the U.S. Trade Representative' => 44890,
    'Small Business Administration' => 14664,
    'Social Security Administration' => 14656,
    'U.S. Securities and Exchange Commission' => 86111,
    'White House / Executive Office of the President' => 78793
  }

  URL = 'https://greatagain.gov/agency-landing-teams-54916f71f462'
  REF_NAME = 'Trump-Pence Transition Team: Agency Landing Teams'
  
  def self.upload
    data = CSV.read(Rails.root.join('data', 'landing_teams.csv'))
    data.shift # remove headers
    list_id = create_list
    data.each { |row| process_row(row, list_id) }
  end

  def self.process_row(row, list_id)
    row_hash = row_to_h(row)
    agency_id = AGENCIES.fetch(row_hash.fetch(:agency))
    person = create_person(row_hash)
    employer = create_employer(row_hash)
    if person.nil? || employer.nil?
      puts "Could not find person with id: #{row_hash.fetch(:person_id)}" if person.nil?
      puts "Could not find org with id: #{row_hash.fetch(:employer_id)}" if employer.nil?
    else
      create_employer_person_relatonship(person, employer)
      relationship_between_person_and_agency(person, agency_id)
      add_to_list(person, list_id)
    end
  end

  def self.add_to_list(person, list_id)
    ListEntity.create(list_id: list_id, entity_id: person.id)
  end

  def self.relationship_between_person_and_agency(person, agency_id)
    r = Relationship.create(
      entity1_id: person.id,
      entity2_id: agency_id,
      category_id: Relationship::POSITION_CATEGORY,
      description1: "Member of Trump's Agency Landing Team",
      description2: "Member of Trump's Agency Landing Team",
      last_user_id: 1)
    Reference.create(object_id: r.id, object_model: 'Relationship', source: URL, name: REF_NAME)
  end
  
  def self.create_employer_person_relatonship(person, employer)
    if Link.where(entity1_id: person.id, entity2_id: employer).blank?
      r = Relationship.create(entity1_id: person.id, entity2_id: employer.id, category_id: Relationship::POSITION_CATEGORY, description1: 'Employee', description2: 'Employee', last_user_id: 1)
      Reference.create(object_id: r.id, object_model: 'Relationship', source: URL, name: REF_NAME)
    end
  end
 
  # input: hash
  def self.create_employer(r)
    return Entity.find_by_id(r.fetch(:employer_id)) if r.fetch(:employer_id).present?
    Entity.create(name: r.fetch(:employer), primary_ext: 'Org')
  end

  # input: hash 
  def self.create_person(r)
    if r.fetch(:person_id).present?
      Entity.find_by_id(r.fetch(:person_id))
    else
      puts "Creating new person: #{r[:name]} - #{blurb_maker(r)}"
      e = Entity.create(name: r.fetch(:name), primary_ext: 'Person', blurb: blurb_maker(r))
      Reference.create(object_id: e.id, object_model: 'Entity', source: URL, name: REF_NAME)
      e
    end
  end

  def self.blurb_maker(r)
    "Member of a Trump agency landing team, works at #{r.fetch(:employer)}"
  end

  def self.row_to_h(row)
    [:agency, :name, :employer, :funding_source, :person_id, :employer_id].zip(row).to_h
  end

  # -> int
  def self.create_list
    l = List.create!(name: "Trump's Agency Landing Teams")
    l.id
  end
end
