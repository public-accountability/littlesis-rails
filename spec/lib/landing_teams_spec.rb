require 'rails_helper'
require Rails.root.join('lib', 'task-helpers', 'landing_teams.rb')

describe 'LandingTeams' do
  before(:all) do
    Entity.skip_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.start
  end

  after(:all) do 
    Entity.set_callback(:create, :after, :create_primary_ext)
    DatabaseCleaner.clean
  end

  it 'has AGENCIES hash' do
    expect(LandingTeams::AGENCIES).to be_a Hash
  end

  describe 'row_to_h' do
    it 'converts row to hash' do
      r = ['Consumer Financial Protection Bureau', 'Paul Atkins', 'Patomak Global Partners LLC', 'Volunteer', '252940', nil]
      h = LandingTeams.row_to_h r
      expect(h).to be_a Hash
      expect(h.fetch(:agency)).to eql 'Consumer Financial Protection Bureau'
      expect(h.fetch(:name)).to eql 'Paul Atkins'
      expect(h.fetch(:employer)).to eql 'Patomak Global Partners LLC'
      expect(h.fetch(:person_id)).to eql '252940'
      expect(h.fetch(:employer_id)).to be nil
    end
  end

  describe 'create_person' do
    it 'creates a new entity' do
      h = {person_id: nil, name: 'free-market freak', employer: 'capital' }
      expect { LandingTeams.create_person(h) }.to change { Entity.count }.by(1)
      expect { LandingTeams.create_person(h) }.to change { Reference.count }.by(1)
      person = LandingTeams.create_person(h)
      expect(person).to be_a Entity
      expect(person.blurb).to eql 'Member of a Trump agency landing team, works at capital'
    end

    it 'returns the person if person_id is there' do
      p = create(:person, name: 'trump fan')
      h = { person_id: p.id }
      person = LandingTeams.create_person(h)
      expect(person).to be_a Entity
      expect(person.name).to eql 'trump fan'
      expect(person.id).to eql p.id
    end
  end

  describe 'create_employer' do
    it 'creates a new entity' do
      h = { employer_id: nil,  employer: 'capital' }
      expect { LandingTeams.create_employer(h) }.to change { Entity.count }.by(1)
      e = LandingTeams.create_employer(h)
      expect(e).to be_a Entity
      expect(e.name).to eql 'capital'
    end

    it 'returns the entity if person_id is there' do
      e = create(:mega_corp_llc)
      h = { employer_id: e.id, employer: 'capital' }
      expect { LandingTeams.create_employer(h) }.not_to change { Entity.count }
      employer = LandingTeams.create_employer(h)
      expect(employer).to be_a Entity
      expect(employer.id).to eql e.id
    end
  end

  describe 'create_employer_person_relatonship' do
    before do
      @person = create(:person)
      @employer = create(:mega_corp_llc)
    end

    it 'creates relationship if it does not exist' do
      expect { LandingTeams.create_employer_person_relatonship(@person, @employer) }.to change { Relationship.count }.by(1)
      expect { LandingTeams.create_employer_person_relatonship(@person, @employer) }.not_to change { Relationship.count }
    end

    it 'creates reference if it does not exist' do
      expect { LandingTeams.create_employer_person_relatonship(@person, @employer) }.to change { Reference.count }.by(1)
      expect { LandingTeams.create_employer_person_relatonship(@person, @employer) }.not_to change { Reference.count }
    end
  end

  describe 'relationship_between_person_and_agency' do
    before do
      @person = create(:person)
      @agency_id = create(:mega_corp_llc).id
    end

    it 'creates relationship' do
      expect { LandingTeams.relationship_between_person_and_agency(@person, @agency_id) }
        .to change { Relationship.count }.by(1)
    end

    it 'creates Reference' do
      expect { LandingTeams.relationship_between_person_and_agency(@person, @agency_id) }
        .to change { Reference.count }.by(1)
    end
  end

  describe 'add_to_list' do
    before do
      @person = create(:person)
      @list_id = LandingTeams.create_list
    end
    it 'adds person to list' do
      expect { LandingTeams.add_to_list(@person, @list_id) }.to change { ListEntity.count }.by(1)
      expect(List.find(@list_id).entities.count).to eql 1
    end
  end

end
